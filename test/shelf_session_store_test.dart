import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/core/metadata/shelf_reading.dart';
import 'package:my_library/core/storage/library_paths.dart';
import 'package:my_library/data/shelf_session_store.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temp;
  late ShelfSessionStore store;
  late File source;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('mylibrary_session_');
    store = ShelfSessionStore(LibraryPaths(temp));
    source = File(p.join(temp.path, 'picked.jpg'));
    await source.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await temp.exists()) {
      await temp.delete(recursive: true);
    }
  });

  ShelfSession session() {
    return ShelfSession(
      shelfId: 3,
      rowId: 7,
      photoPath: source.path,
      shelves: const [
        RecognizedShelf(
          books: [
            RecognizedSpine(title: 'Мастер и Маргарита', author: 'Булгаков', uncertain: false),
            RecognizedSpine(
              title: 'Идиот',
              author: '',
              uncertain: true,
              isbn: '9785170000000',
            ),
          ],
        ),
        RecognizedShelf(
          books: [RecognizedSpine(title: 'Обломов', author: 'Гончаров', uncertain: false)],
        ),
      ],
      settled: const {'0:0': true, '1:0': false},
      createdAt: DateTime.utc(2026, 11, 13, 10),
    );
  }

  test('returns null when nothing is stored', () async {
    expect(await store.load(), isNull);
  });

  test('round trips the session and copies the photo', () async {
    final saved = await store.save(session(), sourcePhoto: source.path);
    final photo = p.join(store.directory.path, 'photo.jpg');
    expect(saved.photoPath, photo);
    expect(await File(photo).readAsBytes(), [1, 2, 3, 4]);

    await source.delete();
    final loaded = await store.load();
    expect(loaded, isNotNull);
    expect(loaded!.shelfId, 3);
    expect(loaded.rowId, 7);
    expect(loaded.photoPath, photo);
    expect(loaded.createdAt, DateTime.utc(2026, 11, 13, 10));
    expect(loaded.settled, {'0:0': true, '1:0': false});
    expect(loaded.shelves, hasLength(2));
    final idiot = loaded.shelves[0].books[1];
    expect(idiot.title, 'Идиот');
    expect(idiot.author, '');
    expect(idiot.isbn, '9785170000000');
    expect(idiot.uncertain, isTrue);
    expect(loaded.total, 3);
    expect(loaded.pending, 1);
  });

  test('saving again keeps the photo and replaces the marks', () async {
    final saved = await store.save(session(), sourcePhoto: source.path);
    await store.save(
      saved.copyWith(settled: {...saved.settled, '0:1': true}, rowId: null),
    );
    final loaded = await store.load();
    expect(loaded!.pending, 0);
    expect(loaded.rowId, isNull);
    expect(loaded.shelfId, 3);
    expect(await File(loaded.photoPath).exists(), isTrue);
  });

  test('clear removes the folder', () async {
    await store.save(session(), sourcePhoto: source.path);
    await store.clear();
    expect(await store.directory.exists(), isFalse);
    expect(await store.load(), isNull);
  });

  test('corrupt json is discarded', () async {
    await store.save(session(), sourcePhoto: source.path);
    await File(p.join(store.directory.path, 'session.json')).writeAsString('{"version":');
    expect(await store.load(), isNull);
    expect(await store.directory.exists(), isFalse);
  });

  test('unknown version is discarded', () async {
    await store.save(session(), sourcePhoto: source.path);
    await File(p.join(store.directory.path, 'session.json'))
        .writeAsString('{"version":99,"shelves":[],"settled":{}}');
    expect(await store.load(), isNull);
    expect(await store.directory.exists(), isFalse);
  });

  test('missing photo is discarded', () async {
    await store.save(session(), sourcePhoto: source.path);
    await File(p.join(store.directory.path, 'photo.jpg')).delete();
    expect(await store.load(), isNull);
    expect(await store.directory.exists(), isFalse);
  });
}
