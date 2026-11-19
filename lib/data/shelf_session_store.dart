import 'dart:convert';
import 'dart:io';

import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:path/path.dart' as p;

const _sessionVersion = 1;
const _unset = Object();

class ShelfSession {
  const ShelfSession({
    required this.shelfId,
    required this.rowId,
    required this.photoPath,
    required this.shelves,
    required this.settled,
    required this.createdAt,
  });

  final int? shelfId;
  final int? rowId;
  final String photoPath;
  final List<RecognizedShelf> shelves;
  final Map<String, bool> settled;
  final DateTime createdAt;

  static String key(int shelf, int index) => '$shelf:$index';

  int get total {
    var count = 0;
    for (final shelf in shelves) {
      count += shelf.books.length;
    }
    return count;
  }

  int get pending {
    var count = 0;
    for (var s = 0; s < shelves.length; s++) {
      for (var i = 0; i < shelves[s].books.length; i++) {
        if (!settled.containsKey(key(s, i))) {
          count++;
        }
      }
    }
    return count;
  }

  ShelfSession copyWith({
    Object? shelfId = _unset,
    Object? rowId = _unset,
    String? photoPath,
    List<RecognizedShelf>? shelves,
    Map<String, bool>? settled,
    DateTime? createdAt,
  }) {
    return ShelfSession(
      shelfId: identical(shelfId, _unset) ? this.shelfId : shelfId as int?,
      rowId: identical(rowId, _unset) ? this.rowId : rowId as int?,
      photoPath: photoPath ?? this.photoPath,
      shelves: shelves ?? this.shelves,
      settled: settled ?? this.settled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'version': _sessionVersion,
      'shelfId': shelfId,
      'rowId': rowId,
      'photoPath': photoPath,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'settled': settled,
      'shelves': [
        for (final shelf in shelves)
          {
            'books': [
              for (final book in shelf.books)
                {
                  'title': book.title,
                  'author': book.author,
                  'isbn': book.isbn,
                  'uncertain': book.uncertain,
                },
            ],
          },
      ],
    };
  }

  static ShelfSession fromJson(Map<String, Object?> json) {
    if (json['version'] != _sessionVersion) {
      throw const FormatException('Unknown shelf session version');
    }
    final shelvesJson = json['shelves'];
    final settledJson = json['settled'];
    final createdAt = DateTime.parse(json['createdAt']! as String);
    if (shelvesJson is! List || settledJson is! Map) {
      throw const FormatException('Malformed shelf session');
    }
    return ShelfSession(
      shelfId: json['shelfId'] as int?,
      rowId: json['rowId'] as int?,
      photoPath: json['photoPath']! as String,
      createdAt: createdAt,
      settled: {
        for (final entry in settledJson.entries)
          entry.key as String: entry.value as bool,
      },
      shelves: [
        for (final shelf in shelvesJson)
          RecognizedShelf(
            books: [
              for (final book in (shelf as Map)['books'] as List)
                RecognizedSpine(
                  title: (book as Map)['title'] as String,
                  author: book['author'] as String,
                  isbn: book['isbn'] as String,
                  uncertain: book['uncertain'] as bool,
                ),
            ],
          ),
      ],
    );
  }
}

class ShelfSessionStore {
  ShelfSessionStore(this.paths);

  final LibraryPaths paths;

  Directory get directory => Directory(p.join(paths.root.path, 'shelf_session'));

  File get _sessionFile => File(p.join(directory.path, 'session.json'));

  File get _photoFile => File(p.join(directory.path, 'photo.jpg'));

  Future<ShelfSession?> load() async {
    if (!await _sessionFile.exists()) {
      await _discard();
      return null;
    }
    try {
      final decoded = jsonDecode(await _sessionFile.readAsString());
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Malformed shelf session');
      }
      final session = ShelfSession.fromJson(decoded);
      if (!await _photoFile.exists()) {
        throw const FormatException('Shelf session photo is missing');
      }
      return session.copyWith(photoPath: _photoFile.path);
    } on Object {
      await _discard();
      return null;
    }
  }

  Future<ShelfSession> save(ShelfSession session, {String? sourcePhoto}) async {
    await directory.create(recursive: true);
    var stored = session;
    if (sourcePhoto != null && !p.equals(sourcePhoto, _photoFile.path)) {
      final temp = File('${_photoFile.path}.tmp');
      await File(sourcePhoto).copy(temp.path);
      await temp.rename(_photoFile.path);
      stored = session.copyWith(photoPath: _photoFile.path);
    }
    final temp = File('${_sessionFile.path}.tmp');
    await temp.writeAsString(jsonEncode(stored.toJson()), flush: true);
    await temp.rename(_sessionFile.path);
    return stored;
  }

  Future<void> clear() async {
    for (var attempt = 0;; attempt++) {
      if (!await directory.exists()) {
        return;
      }
      try {
        await directory.delete(recursive: true);
        return;
      } on FileSystemException {
        // Windows may briefly hold a lock on a file that was just written or deleted.
        if (attempt >= 4) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 50 * (attempt + 1)));
      }
    }
  }

  Future<void> _discard() async {
    try {
      await clear();
    } on FileSystemException {
      return;
    }
  }
}
