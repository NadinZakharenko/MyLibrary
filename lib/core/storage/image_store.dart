import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:my_library/core/storage/library_paths.dart';

class ImageStore {
  ImageStore(this.paths);

  final LibraryPaths paths;

  Future<void> ensureDirs() async {
    await paths.coversDir.create(recursive: true);
    await paths.photosDir.create(recursive: true);
  }

  Future<String> saveBytes(
    Uint8List bytes, {
    required bool cover,
    String extension = 'jpg',
  }) async {
    await ensureDirs();
    final safeExtension = extension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final suffix = safeExtension.isEmpty ? 'jpg' : safeExtension.toLowerCase();
    final name = '${DateTime.now().microsecondsSinceEpoch}.$suffix';
    final directory = cover ? paths.coversDir : paths.photosDir;
    final file = File(p.join(directory.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return cover ? 'covers/$name' : 'photos/$name';
  }

  Future<String> copyIntoLibrary(File source, {required bool cover}) async {
    final bytes = await source.readAsBytes();
    final extension = p.extension(source.path).replaceFirst('.', '');
    return saveBytes(bytes, cover: cover, extension: extension);
  }

  /// Null when the stored path would point outside the media folder.
  File? resolve(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    if (normalized.isEmpty ||
        normalized.contains(':') ||
        p.posix.isAbsolute(normalized)) {
      return null;
    }
    final root = p.normalize(p.absolute(paths.mediaDir.path));
    final candidate = p.normalize(p.join(root, normalized));
    if (!p.isWithin(root, candidate)) {
      return null;
    }
    return File(candidate);
  }

  Future<void> deleteRelative(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return;
    }
    final file = resolve(relativePath);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }
}
