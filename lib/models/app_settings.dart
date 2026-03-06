enum BackgroundTheme {
  warmCream,
  skyBlue,
}

extension BackgroundThemeX on BackgroundTheme {
  String get label {
    switch (this) {
      case BackgroundTheme.warmCream:
        return 'Warm';
      case BackgroundTheme.skyBlue:
        return 'Sky Blue';
    }
  }
}

class AppSettings {
  final BackgroundTheme backgroundTheme;

  /// Cloud drift speed multiplier.
  /// 0.3 = very slow, 1.0 = default, 3.0 = fast.
  final double cloudSpeedMultiplier;

  const AppSettings({
    this.backgroundTheme = BackgroundTheme.warmCream,
    this.cloudSpeedMultiplier = 1.0,
  });

  AppSettings copyWith({
    BackgroundTheme? backgroundTheme,
    double? cloudSpeedMultiplier,
  }) {
    return AppSettings(
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      cloudSpeedMultiplier: cloudSpeedMultiplier ?? this.cloudSpeedMultiplier,
    );
  }
}
