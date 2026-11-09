import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_flutter/data/book_repository.dart';
import 'package:hisn_almuslim_flutter/utils/arabic_text.dart';

void main() {
  late BookRepository repository;

  setUpAll(() {
    final content = File('assets/data/hisn-book.json').readAsStringSync();
    repository = BookRepository.fromJson(content);
  });

  group('complete local book data', () {
    test('contains all verified chapters and remembrance blocks', () {
      expect(repository.metadata.totalChapterCount, 135);
      expect(repository.metadata.totalBlockCount, 320);
      expect(repository.chapters, hasLength(135));
      expect(repository.categories, hasLength(13));
    });

    test('assigns every chapter to one primary category', () {
      final ids = repository.categories
          .expand((section) => section.chapterIds)
          .toList(growable: false);
      expect(ids, hasLength(135));
      expect(ids.toSet(), hasLength(135));
      expect(ids.every((id) => repository.chapterById(id) != null), isTrue);
    });

    test('resolves all quick-access chapters', () {
      for (final section in repository.quickSections) {
        expect(
          repository.chaptersFor(section),
          hasLength(section.chapterIds.length),
        );
      }
    });

    test('returns previous and next chapters in order', () {
      final chapter = repository.chapterById('chapter-027')!;
      final neighbors = repository.neighbors(chapter);
      expect(neighbors.previous?.id, 'chapter-026');
      expect(neighbors.next?.id, 'chapter-028');
    });
  });

  group('Arabic search', () {
    test('normalizes tashkeel and common letter variants', () {
      expect(ArabicText.normalize('أَذْكَارُ الصَّبَاحِ'), 'اذكار الصباح');
      expect(ArabicText.normalize('إلى'), 'الي');
    });

    test('finds a chapter by its unvocalized Arabic title', () {
      final results = repository.search('اذكار الصباح');
      expect(results, isNotEmpty);
      expect(results.first.chapter.id, 'chapter-027');
    });

    test('finds words within remembrance text', () {
      final results = repository.search('الحمد لله');
      expect(results, isNotEmpty);
      expect(
        results.any((result) => result.excerpt.contains('الحَمْدُ')),
        isTrue,
      );
    });

    test('does not search a one-character query', () {
      expect(repository.search('ا'), isEmpty);
    });
  });
}
