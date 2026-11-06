import 'package:drift/native.dart';
import 'package:my_library/core/database/app_database.dart';
import 'package:my_library/core/storage/library_paths.dart';

class DatabaseHandle {
  DatabaseHandle(this.paths);

  final LibraryPaths paths;
  AppDatabase? _database;
  var _open = true;

  AppDatabase get database {
    if (!_open) {
      throw StateError('База закрыта');
    }
    return _database ??= AppDatabase(NativeDatabase(paths.databaseFile));
  }

  Future<void> close() async {
    _open = false;
    final current = _database;
    _database = null;
    if (current != null) {
      await current.close();
    }
  }
}
