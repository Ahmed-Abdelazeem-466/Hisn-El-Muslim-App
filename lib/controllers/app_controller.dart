import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

class AppController extends ChangeNotifier {
  AppController._(
    this._preferences, {
    required this._themePreference,
    required double readerFontSize,
    required this._lastChapterId,
    required this._lastBlockId,
  }) : _readerFontSize = readerFontSize.clamp(19, 31);

  static const _themeKey = 'theme_preference';
  static const _fontSizeKey = 'reader_font_size';
  static const _lastChapterKey = 'last_chapter_id';
  static const _lastBlockKey = 'last_block_id';

  static Future<AppController> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedTheme = preferences.getString(_themeKey);
    final theme = ThemePreference.values.firstWhere(
      (value) => value.name == storedTheme,
      orElse: () => ThemePreference.system,
    );
    return AppController._(
      preferences,
      themePreference: theme,
      readerFontSize: preferences.getDouble(_fontSizeKey) ?? 23,
      lastChapterId: preferences.getString(_lastChapterKey),
      lastBlockId: preferences.getString(_lastBlockKey),
    );
  }

  final SharedPreferences _preferences;
  ThemePreference _themePreference;
  double _readerFontSize;
  String? _lastChapterId;
  String? _lastBlockId;

  ThemePreference get themePreference => _themePreference;
  double get readerFontSize => _readerFontSize;
  String? get lastChapterId => _lastChapterId;
  String? get lastBlockId => _lastBlockId;

  ThemeMode get themeMode => switch (_themePreference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  Future<void> setTheme(ThemePreference value) async {
    if (_themePreference == value) return;
    _themePreference = value;
    notifyListeners();
    await _preferences.setString(_themeKey, value.name);
  }

  Future<void> toggleTheme(Brightness currentBrightness) {
    return setTheme(
      currentBrightness == Brightness.dark
          ? ThemePreference.light
          : ThemePreference.dark,
    );
  }

  Future<void> increaseFontSize() => setReaderFontSize(_readerFontSize + 2);
  Future<void> decreaseFontSize() => setReaderFontSize(_readerFontSize - 2);

  Future<void> setReaderFontSize(double value) async {
    final next = value.clamp(19, 31).toDouble();
    if (next == _readerFontSize) return;
    _readerFontSize = next;
    notifyListeners();
    await _preferences.setDouble(_fontSizeKey, next);
  }

  Future<void> saveReadingPosition(String chapterId, [String? blockId]) async {
    _lastChapterId = chapterId;
    _lastBlockId = blockId;
    notifyListeners();
    await _preferences.setString(_lastChapterKey, chapterId);
    if (blockId == null) {
      await _preferences.remove(_lastBlockKey);
    } else {
      await _preferences.setString(_lastBlockKey, blockId);
    }
  }

  Future<void> resetReadingPosition() async {
    _lastChapterId = null;
    _lastBlockId = null;
    notifyListeners();
    await _preferences.remove(_lastChapterKey);
    await _preferences.remove(_lastBlockKey);
  }
}
