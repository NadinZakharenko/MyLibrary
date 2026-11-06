import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/core/models/home_layout.dart';
import 'package:my_library/features/books/book_card_screen.dart';
import 'package:my_library/features/books/book_list_screen.dart';
import 'package:my_library/features/capture/add_book_screen.dart';
import 'package:my_library/features/capture/capture_flow_screens.dart';
import 'package:my_library/features/capture/shelf_mark_screen.dart';
import 'package:my_library/features/capture/shelf_probe_screen.dart';
import 'package:my_library/features/home/home_screen.dart';
import 'package:my_library/features/library/cabinet_screen.dart';
import 'package:my_library/features/library/shelf_screen.dart';
import 'package:my_library/features/search/search_screen.dart';
import 'package:my_library/features/settings/settings_screen.dart';
import 'package:my_library/features/shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'unplaced',
                    builder: (context, state) => const UnplacedBooksScreen(),
                  ),
                  GoRoute(
                    path: 'group/:stat',
                    builder: (context, state) {
                      final stat = _homeStat(state.pathParameters['stat']);
                      if (stat == null) {
                        return const Scaffold(
                          body: Center(child: Text('Некорректная ссылка')),
                        );
                      }
                      return HomeGroupScreen(stat: stat);
                    },
                  ),
                  GoRoute(
                    path: 'cabinet/:cabinetId',
                    builder: (context, state) => _idPage(
                      state,
                      'cabinetId',
                      (id) => CabinetScreen(
                        cabinetId: id,
                        highlightedShelfId: int.tryParse(
                          state.uri.queryParameters['shelf'] ?? '',
                        ),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'shelf/:shelfId',
                    builder: (context, state) => _idPage(
                      state,
                      'shelfId',
                      (id) => ShelfScreen(shelfId: id),
                    ),
                  ),
                  GoRoute(
                    path: 'row/:rowId',
                    builder: (context, state) => _idPage(
                      state,
                      'rowId',
                      (id) => RowBooksScreen(rowId: id),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add',
                builder: (context, state) => const AddBookScreen(),
                routes: [
                  GoRoute(
                    path: 'manual',
                    builder: (context, state) => const ManualLookupScreen(),
                  ),
                  GoRoute(
                    path: 'shelf',
                    builder: (context, state) => const ShelfProbeScreen(),
                    routes: [
                      GoRoute(
                        path: 'mark',
                        builder: (context, state) {
                          final extra = state.extra;
                          if (extra is! ShelfMarkArgs || extra.path.isEmpty) {
                            return const Scaffold(
                              body: Center(child: Text('Нет снимка полки')),
                            );
                          }
                          return ShelfMarkScreen(
                            imagePath: extra.path,
                            shelfId: extra.shelfId,
                            rowId: extra.rowId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'candidates',
                    builder: (context, state) => const CandidatesScreen(),
                  ),
                  GoRoute(
                    path: 'form',
                    builder: (context, state) => const DraftFormScreen(),
                  ),
                  GoRoute(
                    path: 'batch',
                    builder: (context, state) => const BatchDraftsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/book/:bookId',
        builder: (context, state) =>
            _idPage(state, 'bookId', (id) => BookCardScreen(bookId: id)),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                _idPage(state, 'bookId', (id) => EditBookScreen(bookId: id)),
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const BarcodeScanScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return const Scaffold(body: Center(child: Text('Страница не найдена')));
    },
  );
});

HomeStat? _homeStat(String? raw) {
  if (raw == null) {
    return null;
  }
  for (final stat in HomeStat.values) {
    if (homeStatKey(stat) == raw) {
      return stat;
    }
  }
  return null;
}

Widget _idPage(
  GoRouterState state,
  String name,
  Widget Function(int id) build,
) {
  final id = int.tryParse(state.pathParameters[name] ?? '');
  if (id == null) {
    return const Scaffold(body: Center(child: Text('Некорректная ссылка')));
  }
  return build(id);
}
