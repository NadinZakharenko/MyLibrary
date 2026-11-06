import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LibraryPaths {
  LibraryPaths(this.root);

  final Directory root;

  static Future<LibraryPaths> fromApplicationDocuments() async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(docs.path, 'my_library'));
    await root.create(recursive: true);
    return LibraryPaths(root);
  }

  File get databaseFile => File(p.join(root.path, 'library.sqlite'));

  File get databaseWalFile => File(p.join(root.path, 'library.sqlite-wal'));

  File get databaseShmFile => File(p.join(root.path, 'library.sqlite-shm'));

  Directory get mediaDir => Directory(p.join(root.path, 'media'));

  Directory get coversDir => Directory(p.join(mediaDir.path, 'covers'));

  Directory get photosDir => Directory(p.join(mediaDir.path, 'photos'));

  File get logFile => File(p.join(root.path, 'app.log'));
}
