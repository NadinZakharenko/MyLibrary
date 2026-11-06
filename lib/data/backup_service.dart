import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:my_library/core/database/app_database.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:path/path.dart' as p;

class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupService {
  Future<List<int>> buildArchive({
    required AppDatabase db,
    required LibraryPaths paths,
  }) async {
    final snapshot = File(p.join(paths.root.path, 'library-snapshot.sqlite'));
    await _deleteIfExists(snapshot);
    try {
      final sqlPath = snapshot.path.replaceAll('\\', '/').replaceAll("'", "''");
      await db.customStatement("VACUUM INTO '$sqlPath'");
      await _withDatabase(snapshot, (copy) async {
        await copy.customStatement('PRAGMA secure_delete = ON');
        await _deleteSecrets(copy);
      });
      final archive = Archive();
      final databaseBytes = await snapshot.readAsBytes();
      archive.addFile(
        ArchiveFile('library.sqlite', databaseBytes.length, databaseBytes),
      );
      await _addTree(archive, paths.mediaDir, paths.root);
      return ZipEncoder().encode(archive);
    } finally {
      await _deleteIfExists(snapshot);
    }
  }

  /// Validates the whole archive in a staging folder before the current
  /// library is touched. Local API keys survive the restore.
  Future<void> restore({
    required LibraryPaths paths,
    required List<int> bytes,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw BackupException('Файл не похож на резервную копию.');
    }
    ArchiveFile? databaseFile;
    final mediaFiles = <ArchiveFile>[];
    for (final file in archive.files) {
      if (!file.isFile) {
        continue;
      }
      final name = file.name.replaceAll('\\', '/');
      if (name.contains('..') || name.startsWith('/') || name.contains(':')) {
        throw BackupException('Архив содержит небезопасный путь.');
      }
      if (name == 'library.sqlite') {
        databaseFile = file;
      } else if (name.startsWith('media/')) {
        mediaFiles.add(file);
      }
    }
    if (databaseFile == null) {
      throw BackupException('В архиве нет файла library.sqlite.');
    }
    _checkHeader(databaseFile.content);

    final staging = Directory(p.join(paths.root.path, 'restore-staging'));
    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    await staging.create(recursive: true);
    try {
      final stagedDatabase = File(p.join(staging.path, 'library.sqlite'));
      await stagedDatabase.writeAsBytes(databaseFile.content, flush: true);
      final localSecrets = await _readLocalSecrets(paths.databaseFile);
      await _withDatabase(stagedDatabase, (copy) async {
        await _checkDatabase(copy);
        await _deleteSecrets(copy);
        for (final entry in localSecrets.entries) {
          await copy.into(copy.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(key: entry.key, value: entry.value),
          );
        }
      });

      final stagedMedia = Directory(p.join(staging.path, 'media'));
      for (final file in mediaFiles) {
        final relative = file.name.replaceAll('\\', '/').substring('media/'.length);
        final output = File(p.join(stagedMedia.path, relative));
        await output.parent.create(recursive: true);
        await output.writeAsBytes(file.content, flush: true);
      }

      await _deleteIfExists(paths.databaseFile);
      await _deleteIfExists(paths.databaseWalFile);
      await _deleteIfExists(paths.databaseShmFile);
      if (await paths.mediaDir.exists()) {
        await paths.mediaDir.delete(recursive: true);
      }
      await paths.databaseFile.parent.create(recursive: true);
      await stagedDatabase.rename(paths.databaseFile.path);
      if (await stagedMedia.exists()) {
        await stagedMedia.rename(paths.mediaDir.path);
      }
    } finally {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  void _checkHeader(List<int> bytes) {
    const magic = 'SQLite format 3\u0000';
    if (bytes.length < 100 ||
        ascii.decode(bytes.sublist(0, 16), allowInvalid: true) != magic) {
      throw BackupException('В архиве не база библиотеки.');
    }
    final version =
        (bytes[60] << 24) | (bytes[61] << 16) | (bytes[62] << 8) | bytes[63];
    if (version < 1) {
      throw BackupException('В архиве не база библиотеки.');
    }
    if (version > currentSchemaVersion) {
      throw BackupException(
        'Копия сделана более новой версией приложения. Обновите приложение.',
      );
    }
  }

  Future<void> _checkDatabase(AppDatabase copy) async {
    try {
      final rows = await copy.customSelect('PRAGMA integrity_check').get();
      if (rows.length != 1 || rows.single.data.values.single != 'ok') {
        throw BackupException('База в архиве повреждена.');
      }
      for (final table in copy.allTables) {
        final columns = table.$columns.map((c) => '"${c.name}"').join(', ');
        await copy
            .customSelect(
              'SELECT $columns FROM "${table.actualTableName}" LIMIT 1',
            )
            .get();
      }
    } on BackupException {
      rethrow;
    } catch (_) {
      throw BackupException('База в архиве повреждена.');
    }
  }

  Future<Map<String, String>> _readLocalSecrets(File databaseFile) async {
    if (!await databaseFile.exists()) {
      return const {};
    }
    try {
      return await _withDatabase(databaseFile, (current) async {
        final secrets = <String, String>{};
        for (final key in backupSecretSettings) {
          final row = await (current.select(current.appSettings)
                ..where((t) => t.key.equals(key)))
              .getSingleOrNull();
          final value = row?.value.trim();
          if (value != null && value.isNotEmpty) {
            secrets[key] = value;
          }
        }
        return secrets;
      });
    } catch (_) {
      return const {};
    }
  }

  Future<void> _deleteSecrets(AppDatabase copy) async {
    for (final key in backupSecretSettings) {
      await (copy.delete(copy.appSettings)..where((t) => t.key.equals(key))).go();
    }
  }

  Future<T> _withDatabase<T>(
    File file,
    Future<T> Function(AppDatabase db) action,
  ) async {
    final database = AppDatabase(NativeDatabase(file));
    try {
      return await action(database);
    } finally {
      await database.close();
    }
  }

  Future<void> _addTree(
    Archive archive,
    Directory directory,
    Directory root,
  ) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final name = p
          .relative(entity.path, from: root.path)
          .replaceAll('\\', '/');
      if (name.contains('..')) {
        continue;
      }
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
