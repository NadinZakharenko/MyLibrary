import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/features/shell/app_shell.dart';
import 'package:my_library/router/app_router.dart';
import 'package:my_library/ui/open_book.dart';

void main() {
  late GoRouter appRouter;

  setUp(() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    appRouter = container.read(routerProvider);
  });

  RouteMatchList findMatch(String location) {
    return appRouter.configuration.findMatch(Uri.parse(location));
  }

  for (final location in ['/home/book/7', '/search/book/7', '/add/book/7']) {
    test('$location opens the book inside its tab', () {
      final matches = findMatch(location);

      expect(matches.error, isNull);
      expect(matches.uri.path, location);
      final shell = matches.matches.single;
      expect(shell, isA<ShellRouteMatch>());
      expect(shell.route, isA<StatefulShellRoute>());
      expect(matches.last.matchedLocation, location);
      expect(findMatch('$location/edit').error, isNull);
    });
  }

  test('the old /book address is gone', () {
    expect(findMatch('/book/7').error, isNotNull);
  });

  for (final location in [
    '/add/manual',
    '/add/shelf',
    '/add/shelf/mark',
    '/add/candidates',
    '/add/form',
    '/add/batch',
    '/add/batch/book/7',
    '/add/batch/book/7/edit',
  ]) {
    test('$location opens full screen on the root navigator', () {
      final matches = findMatch(location);

      expect(matches.error, isNull);
      final last = matches.matches.last;
      expect(last, isNot(isA<ShellRouteMatch>()));
      expect(
        (last.route as GoRoute).parentNavigatorKey,
        appRouter.configuration.navigatorKey,
      );
    });
  }

  testWidgets('a book opened from search stays in the search tab', (
    tester,
  ) async {
    final router = _stubRouter('/search');
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(_selectedTab(tester), 1);

    await tester.tap(find.text('Открыть книгу'));
    await tester.pumpAndSettle();
    expect(find.text('Книга /search/book/7'), findsOneWidget);
    expect(_selectedTab(tester), 1);

    await tester.tap(find.text('Главная'));
    await tester.pumpAndSettle();
    expect(find.text('Экран /home'), findsOneWidget);
    expect(_selectedTab(tester), 0);

    await tester.tap(find.text('Поиск'));
    await tester.pumpAndSettle();
    expect(find.text('Книга /search/book/7'), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Экран /search'), findsOneWidget);
    expect(_selectedTab(tester), 1);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Экран /home'), findsOneWidget);
    expect(_selectedTab(tester), 0);
  });

  testWidgets('the add wizard covers the bottom navigation', (tester) async {
    final router = _stubRouter('/add');
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    router.push('/add/form');
    await tester.pumpAndSettle();
    expect(find.text('Форма'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Экран /add'), findsOneWidget);
    expect(_selectedTab(tester), 2);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Экран /home'), findsOneWidget);
  });
}

int _selectedTab(WidgetTester tester) {
  return tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
}

GoRouter _stubRouter(String initialLocation) {
  final rootKey = GlobalKey<NavigatorState>();
  GoRoute book() => GoRoute(
    path: 'book/:id',
    builder: (context, state) => Text('Книга ${state.uri.path}'),
  );
  GoRoute tab(String path, {List<RouteBase> routes = const []}) => GoRoute(
    path: path,
    builder: (context, state) => Column(
      children: [
        Text('Экран $path'),
        Builder(
          builder: (context) => TextButton(
            onPressed: () => openBook(context, 7),
            child: const Text('Открыть книгу'),
          ),
        ),
      ],
    ),
    routes: [book(), ...routes],
  );
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [tab('/home')]),
          StatefulShellBranch(routes: [tab('/search')]),
          StatefulShellBranch(
            routes: [
              tab(
                '/add',
                routes: [
                  GoRoute(
                    path: 'form',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) =>
                        const Scaffold(body: Text('Форма')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [tab('/settings')]),
        ],
      ),
    ],
  );
}
