import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_flutter/controllers/app_controller.dart';
import 'package:hisn_almuslim_flutter/data/book_repository.dart';
import 'package:hisn_almuslim_flutter/screens/home_screen.dart';
import 'package:hisn_almuslim_flutter/screens/reader_screen.dart';
import 'package:hisn_almuslim_flutter/screens/section_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _chapterId(int number) => 'chapter-${number.toString().padLeft(3, '0')}';

List<String> _chapterIds(Iterable<int> numbers) =>
    numbers.map(_chapterId).toList(growable: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BookRepository repository;
  late AppController controller;

  setUpAll(() async {
    final content = File('assets/data/hisn-book.json').readAsStringSync();
    repository = BookRepository.fromJson(content);
    SharedPreferences.setMockInitialValues({});
    controller = await AppController.load();
  });

  test('splits categories into the deterministic chapter distribution', () {
    final expected = <String, List<String>>{
      'daily-day': [
        ..._chapterIds(List<int>.generate(11, (index) => index + 1)),
        _chapterId(27),
      ],
      'daily-night': _chapterIds(List<int>.generate(5, (index) => index + 28)),
      'prayer': [
        ..._chapterIds(List<int>.generate(15, (index) => index + 12)),
        _chapterId(33),
        _chapterId(34),
      ],
      'protection': [
        ..._chapterIds(List<int>.generate(13, (index) => index + 35)),
        _chapterId(83),
        _chapterId(84),
        _chapterId(89),
        _chapterId(93),
        _chapterId(95),
        _chapterId(107),
        ..._chapterIds(List<int>.generate(5, (index) => index + 123)),
        _chapterId(129),
      ],
      'family': [
        _chapterId(48),
        _chapterId(49),
        _chapterId(80),
        _chapterId(81),
        _chapterId(82),
      ],
      'illness': [_chapterId(50), _chapterId(51), _chapterId(52)],
      'death': _chapterIds(List<int>.generate(9, (index) => index + 53)),
      'weather': _chapterIds(List<int>.generate(7, (index) => index + 62)),
      'food-fasting': _chapterIds(List<int>.generate(9, (index) => index + 69)),
      'social': [
        _chapterId(78),
        _chapterId(79),
        ..._chapterIds(List<int>.generate(4, (index) => index + 85)),
        ..._chapterIds(List<int>.generate(3, (index) => index + 90)),
        _chapterId(94),
        ..._chapterIds(List<int>.generate(8, (index) => index + 108)),
        _chapterId(128),
        _chapterId(133),
      ],
      'travel': _chapterIds(List<int>.generate(11, (index) => index + 96)),
      'hajj': _chapterIds(List<int>.generate(7, (index) => index + 116)),
      'remembrance': const [
        'introduction',
        'virtues-of-remembrance',
        'chapter-130',
        'chapter-131',
        'chapter-132',
      ],
    };

    expect(repository.metadata.totalChapterCount, 135);
    expect(repository.metadata.totalBlockCount, 320);
    expect(repository.chapters, hasLength(135));
    expect(repository.categories, hasLength(13));
    expect(
      repository.categories.map((section) => section.id).toList(),
      expected.keys.toList(),
    );

    for (final entry in expected.entries) {
      final section = repository.sectionById(entry.key);
      expect(section, isNotNull, reason: 'missing category ${entry.key}');
      expect(section!.chapterIds, entry.value);
      expect(
        repository.chaptersFor(section).map((chapter) => chapter.id).toList(),
        entry.value,
      );
      for (final chapterId in entry.value) {
        expect(repository.chapterById(chapterId)!.categoryId, entry.key);
      }
    }

    expect(repository.sectionById('weather')!.title, 'الطقس');
    expect(repository.sectionById('food-fasting')!.title, 'الطعام والصيام');

    expect(
      repository.chapters
          .map((chapter) => chapter.categoryId)
          .every((categoryId) => expected.containsKey(categoryId)),
      isTrue,
    );
  });

  test('keeps quick sections stable while avoiding category ID collisions', () {
    expect(repository.quickSections.map((section) => section.id).toList(), [
      'morning',
      'evening',
      'night',
      'home',
    ]);
    expect(
      repository.quickSections.map((section) => section.id).toSet(),
      hasLength(4),
    );
    expect(
      repository.quickSections
          .map((section) => section.id)
          .toSet()
          .intersection(
            repository.categories.map((section) => section.id).toSet(),
          ),
      isEmpty,
    );
  });

  testWidgets('navigates from a category to its chapter list and reader', (
    tester,
  ) async {
    final section = repository.sectionById('daily-day')!;
    final chapter = repository.chapterById(section.chapterIds.first)!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            repository: repository,
            controller: controller,
            openSearch: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final categoryTitle = find.text(section.title).last;
    final categoryCard = find.ancestor(
      of: categoryTitle,
      matching: find.byType(Card),
    );
    expect(categoryTitle, findsOneWidget);
    expect(categoryCard, findsOneWidget);
    await tester.scrollUntilVisible(
      categoryCard,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(categoryCard);
    await tester.pumpAndSettle();
    await tester.tap(categoryCard);
    await tester.pumpAndSettle();

    expect(find.byType(SectionScreen), findsOneWidget);
    expect(
      find.text('${section.chapterIds.length} بابًا مرتبة بحسب الكتاب'),
      findsOneWidget,
    );
    final chapterTile = find.widgetWithText(ListTile, chapter.title);
    expect(chapterTile, findsOneWidget);
    await tester.tap(chapterTile);
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ReaderScreen),
        matching: find.text(chapter.title),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ReaderScreen),
        matching: find.text('1 / ${chapter.blocks.length}'),
      ),
      findsOneWidget,
    );
  });
}
