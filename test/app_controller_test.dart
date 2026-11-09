import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_flutter/controllers/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads safe default preferences', () async {
    final controller = await AppController.load();
    expect(controller.themePreference, ThemePreference.system);
    expect(controller.themeMode, ThemeMode.system);
    expect(controller.readerFontSize, 23);
    expect(controller.lastChapterId, isNull);
  });

  test(
    'restores persisted dark mode, font size, and reading position',
    () async {
      SharedPreferences.setMockInitialValues({
        'theme_preference': 'dark',
        'reader_font_size': 27.0,
        'last_chapter_id': 'chapter-027',
        'last_block_id': 'chapter-027-block-1',
      });
      final controller = await AppController.load();
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.readerFontSize, 27);
      expect(controller.lastChapterId, 'chapter-027');
      expect(controller.lastBlockId, 'chapter-027-block-1');
    },
  );

  test('clamps font size and resets saved reading progress', () async {
    final controller = await AppController.load();
    await controller.setReaderFontSize(100);
    expect(controller.readerFontSize, 31);
    await controller.setReaderFontSize(1);
    expect(controller.readerFontSize, 19);

    await controller.saveReadingPosition('chapter-028', 'chapter-028-block-1');
    expect(controller.lastChapterId, 'chapter-028');
    await controller.resetReadingPosition();
    expect(controller.lastChapterId, isNull);
    expect(controller.lastBlockId, isNull);
  });
}
