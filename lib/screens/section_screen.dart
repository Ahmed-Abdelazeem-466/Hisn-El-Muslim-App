import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';
import '../models/hisn_models.dart';
import 'reader_screen.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({
    super.key,
    required this.repository,
    required this.controller,
    required this.section,
  });

  final BookRepository repository;
  final AppController controller;
  final HisnSection section;

  @override
  Widget build(BuildContext context) {
    final chapters = repository.chaptersFor(section);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        itemCount: chapters.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${chapters.length} بابًا مرتبة بحسب الكتاب',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final chapter = chapters[index - 1];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: theme.scaffoldBackgroundColor,
                foregroundColor: theme.colorScheme.primary,
                child: Text(
                  '${chapter.number > 0 ? chapter.number : index}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${chapter.blocks.length} ${chapter.blocks.length == 1 ? 'ذكر' : 'أذكار'}',
              ),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReaderScreen(
                    repository: repository,
                    controller: controller,
                    chapter: chapter,
                    section: section,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
