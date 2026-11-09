class HisnMetadata {
  const HisnMetadata({
    required this.title,
    required this.subtitle,
    required this.author,
    required this.totalChapterCount,
    required this.totalBlockCount,
  });

  factory HisnMetadata.fromJson(Map<String, dynamic> json) {
    return HisnMetadata(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      author: json['author'] as String,
      totalChapterCount: (json['totalChapterCount'] as num).toInt(),
      totalBlockCount: (json['totalBlockCount'] as num).toInt(),
    );
  }

  final String title;
  final String subtitle;
  final String author;
  final int totalChapterCount;
  final int totalBlockCount;
}

class HisnSection {
  const HisnSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.chapterIds,
    this.description,
    this.eyebrow,
  });

  factory HisnSection.fromJson(Map<String, dynamic> json) {
    return HisnSection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eyebrow: json['eyebrow'] as String?,
      icon: json['icon'] as String,
      color: json['color'] as String,
      chapterIds: (json['chapterIds'] as List<dynamic>).cast<String>(),
    );
  }

  final String id;
  final String title;
  final String? description;
  final String? eyebrow;
  final String icon;
  final String color;
  final List<String> chapterIds;
}

class HisnBlock {
  const HisnBlock({
    required this.id,
    required this.text,
    required this.reference,
    required this.count,
  });

  factory HisnBlock.fromJson(Map<String, dynamic> json) {
    return HisnBlock(
      id: json['id'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 1,
    );
  }

  final String id;
  final String text;
  final String reference;
  final int count;
}

class HisnChapter {
  const HisnChapter({
    required this.id,
    required this.number,
    required this.title,
    required this.categoryId,
    required this.blocks,
  });

  factory HisnChapter.fromJson(Map<String, dynamic> json) {
    return HisnChapter(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      blocks: (json['blocks'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HisnBlock.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final int number;
  final String title;
  final String categoryId;
  final List<HisnBlock> blocks;
}

class SearchResult {
  const SearchResult({required this.chapter, required this.excerpt});

  final HisnChapter chapter;
  final String excerpt;
}
