import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/ui/spine_plank.dart';

void main() {
  testWidgets('shows spine titles and opens the book on a short tap', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SpinePlank(
              books: [
                _book(7, 'Война и мир'),
                _book(8, 'Мастер и Маргарита'),
              ],
              onReorder: (_) async {},
            ),
          ),
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) => Scaffold(
            body: Text('opened ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Война и мир'), findsOneWidget);
    expect(find.text('Мастер и Маргарита'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Война и мир'));
    await tester.pumpAndSettle();

    expect(find.text('opened 7'), findsOneWidget);
  });

  testWidgets('empty plank stays a shelf without spines', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpinePlank(books: const [], onReorder: (_) async {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('На этом ряду пока нет книг'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filled check is a normal menu item with the icon on the right', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Изменить полку')),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Полка заполнена'),
                    Icon(Icons.check),
                  ],
                ),
              ),
              const PopupMenuItem(value: 2, child: Text('Удалить полку')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<int>));
    await tester.pumpAndSettle();

    expect(find.text('Полка заполнена'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

BookSummary _book(int id, String title) {
  return BookSummary(
    id: id,
    title: title,
    authorsLabel: '',
    genresLabel: '',
    locationPath: '',
    positionIndex: 0,
    createdAt: DateTime.utc(2026),
  );
}
