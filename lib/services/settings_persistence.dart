import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsPersistence {
  static const String _bgThemeKey = 'setting_bg_theme';
  static const String _cloudSpeedKey = 'setting_cloud_speed';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_bgThemeKey) ?? 0;
    final cloudSpeed = prefs.getDouble(_cloudSpeedKey) ?? 1.0;
    return AppSettings(
      backgroundTheme: BackgroundTheme.values[
          themeIndex.clamp(0, BackgroundTheme.values.length - 1)],
      cloudSpeedMultiplier: cloudSpeed.clamp(0.3, 3.0),
    );
  }

  static Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bgThemeKey, settings.backgroundTheme.index);
    await prefs.setDouble(_cloudSpeedKey, settings.cloudSpeedMultiplier);
  }
}
