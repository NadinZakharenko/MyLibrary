import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/theme/app_theme.dart';
import 'package:my_library/core/theme/theme_choice.dart';
import 'package:my_library/data/library_reminders.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/router/app_router.dart';

class MyLibraryApp extends ConsumerStatefulWidget {
  const MyLibraryApp({super.key});

  @override
  ConsumerState<MyLibraryApp> createState() => _MyLibraryAppState();
}

class _MyLibraryAppState extends ConsumerState<MyLibraryApp> {
  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final enabled = await ref.read(libraryRepositoryProvider).loggingEnabled();
      final log = ref.read(appLogProvider);
      log.enabled = enabled;
      await log.write('Приложение запущено');
      if (!mounted) {
        return;
      }
      ref.listenManual<LibraryReminders>(
        libraryRemindersProvider,
        (_, reminders) => _connect(reminders),
        fireImmediately: true,
      );
      final launched = await ref.read(libraryRemindersProvider).launchBookId();
      if (launched != null && mounted) {
        _openBook(launched);
      }
    });
  }

  /// The repository is rebuilt after a restore, so the hook is set again.
  void _connect(LibraryReminders reminders) {
    reminders.onOpenBook = _openBook;
    reminders.repository.afterBooksChanged = reminders.sync;
    reminders.sync();
  }

  void _openBook(int id) {
    ref.read(routerProvider).go('/home/book/$id');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final choice =
        ref.watch(themeChoiceProvider).asData?.value ?? AppThemeChoice.system;
    return MaterialApp.router(
      title: 'Моя библиотека',
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode(choice),
      routerConfig: router,
    );
  }
}

ThemeMode _themeMode(AppThemeChoice choice) {
  return switch (choice) {
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark => ThemeMode.dark,
    AppThemeChoice.system => ThemeMode.system,
  };
}
