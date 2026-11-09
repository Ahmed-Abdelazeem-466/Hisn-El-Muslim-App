import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hisn_models.dart';
import '../utils/arabic_text.dart';

class BookRepository {
  BookRepository._({
    required this.metadata,
    required this.quickSections,
    required this.categories,
    required this.chapters,
  }) : _chapterById = {for (final chapter in chapters) chapter.id: chapter},
       _sectionById = {
         for (final section in [...quickSections, ...categories])
           section.id: section,
       };

  static Future<BookRepository> load() async {
    final content = await rootBundle.loadString('assets/data/hisn-book.json');
    return BookRepository.fromJson(content);
  }

  factory BookRepository.fromJson(String content) {
    final json = jsonDecode(content) as Map<String, dynamic>;
    return BookRepository._(
      metadata: HisnMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      quickSections: (json['quickSections'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HisnSection.fromJson)
          .toList(growable: false),
      categories: (json['categories'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HisnSection.fromJson)
          .toList(growable: false),
      chapters: (json['chapters'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HisnChapter.fromJson)
          .toList(growable: false),
    );
  }

  final HisnMetadata metadata;
  final List<HisnSection> quickSections;
  final List<HisnSection> categories;
  final List<HisnChapter> chapters;
  final Map<String, HisnChapter> _chapterById;
  final Map<String, HisnSection> _sectionById;

  HisnChapter? chapterById(String? id) => id == null ? null : _chapterById[id];

  HisnSection? sectionById(String? id) => id == null ? null : _sectionById[id];

  List<HisnChapter> chaptersFor(HisnSection section) {
    return section.chapterIds
        .map((id) => _chapterById[id])
        .whereType<HisnChapter>()
        .toList(growable: false);
  }

  ({HisnChapter? previous, HisnChapter? next}) neighbors(
    HisnChapter chapter, [
    HisnSection? section,
  ]) {
    final source = section == null ? chapters : chaptersFor(section);
    final index = source.indexWhere((item) => item.id == chapter.id);
    if (index < 0) return (previous: null, next: null);
    return (
      previous: index > 0 ? source[index - 1] : null,
      next: index < source.length - 1 ? source[index + 1] : null,
    );
  }

  List<SearchResult> search(String query, {int limit = 60}) {
    final normalizedQuery = ArabicText.normalize(query);
    if (normalizedQuery.length < 2) return const [];
    final titles = <SearchResult>[];
    final body = <SearchResult>[];

    for (final chapter in chapters) {
      if (ArabicText.normalize(chapter.title).contains(normalizedQuery)) {
        titles.add(
          SearchResult(
            chapter: chapter,
            excerpt: chapter.blocks.isEmpty
                ? chapter.title
                : chapter.blocks.first.text,
          ),
        );
        continue;
      }
      for (final block in chapter.blocks) {
        if (ArabicText.normalize(block.text).contains(normalizedQuery) ||
            ArabicText.normalize(block.reference).contains(normalizedQuery)) {
          body.add(
            SearchResult(
              chapter: chapter,
              excerpt: ArabicText.excerpt(block.text, normalizedQuery),
            ),
          );
          break;
        }
      }
    }
    return [...titles, ...body].take(limit).toList(growable: false);
  }
}
