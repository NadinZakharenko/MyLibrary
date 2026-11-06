enum AppThemeChoice { light, dark, system }

const themeModeSettingKey = 'theme_mode';

String themeChoiceStorage(AppThemeChoice choice) {
  return switch (choice) {
    AppThemeChoice.light => 'light',
    AppThemeChoice.dark => 'dark',
    AppThemeChoice.system => 'system',
  };
}

AppThemeChoice themeChoiceFromStorage(String? raw) {
  return switch (raw) {
    'light' => AppThemeChoice.light,
    'dark' => AppThemeChoice.dark,
    'system' => AppThemeChoice.system,
    _ => AppThemeChoice.system,
  };
}

String themeChoiceLabel(AppThemeChoice choice) {
  return switch (choice) {
    AppThemeChoice.light => 'Светлая',
    AppThemeChoice.dark => 'Тёмная',
    AppThemeChoice.system => 'Как в системе',
  };
}
