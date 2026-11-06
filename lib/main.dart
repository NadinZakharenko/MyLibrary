import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/app.dart';
import 'package:my_library/core/storage/image_store.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final paths = await LibraryPaths.fromApplicationDocuments();
  await ImageStore(paths).ensureDirs();
  runApp(
    ProviderScope(
      overrides: [libraryPathsProvider.overrideWithValue(paths)],
      child: const MyLibraryApp(),
    ),
  );
}
