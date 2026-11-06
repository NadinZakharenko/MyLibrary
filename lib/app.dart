import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/theme/app_theme.dart';
import 'package:my_library/core/theme/theme_choice.dart';
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
      final repository = ref.read(libraryRepositoryProvider);
      final reminders = ref.read(libraryRemindersProvider);
      repository.afterBooksChanged = reminders.sync;
      await reminders.sync();
    });
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
