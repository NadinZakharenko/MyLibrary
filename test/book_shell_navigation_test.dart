import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/features/shell/app_shell.dart';
import 'package:my_library/router/app_router.dart';

void main() {
  test('the book card route stays inside the navigation shell', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    final matches = router.configuration.findMatch(Uri.parse('/book/7'));

    expect(matches.error, isNull);
    expect(
      matches.matches.map((match) => match.route),
      contains(isA<ShellRoute>()),
    );
    expect(matches.uri.path, '/book/7');
  });

  testWidgets('the bottom navigation stays on a book and opens home', (
    tester,
  ) async {
    libraryNavigationShell = null;
    final router = GoRouter(
      initialLocation: '/book/7',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AppShell(
              location: state.uri.path,
              navigationShell: libraryNavigationShell,
              child: child,
            );
          },
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                libraryNavigationShell = navigationShell;
                return navigationShell;
              },
              branches: [
                for (final location in shellTabLocations)
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: location,
                        builder: (context, state) => Text('Экран $location'),
                      ),
                    ],
                  ),
              ],
            ),
            GoRoute(
              path: '/book/:id',
              builder: (context, state) =>
                  Text('Книга ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('Книга 7'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Поиск'), findsOneWidget);
    expect(find.text('Добавить'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);

    await tester.tap(find.text('Главная'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Экран /home'), findsOneWidget);
    expect(find.text('Книга 7'), findsNothing);
  });
}
