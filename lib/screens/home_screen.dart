import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';
import '../models/hisn_models.dart';
import '../widgets/section_card.dart';
import 'reader_screen.dart';
import 'section_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.controller,
    required this.openSearch,
  });

  final BookRepository repository;
  final AppController controller;
  final VoidCallback openSearch;

  void _openSection(BuildContext context, HisnSection section) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SectionScreen(
          repository: repository,
          controller: controller,
          section: section,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastChapter = repository.chapterById(controller.lastChapterId);
    return CustomScrollView(
      key: const PageStorageKey('home-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حصن المسلم',
                          style: TextStyle(
                            fontSize: 31,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'من أذكار الكتاب والسنة',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'تغيير المظهر',
                    onPressed: () => controller.toggleTheme(theme.brightness),
                    icon: Icon(
                      theme.brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: openSearch,
                child: IgnorePointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن ذكر أو دعاء',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              if (lastChapter != null) ...[
                const SizedBox(height: 14),
                Card(
                  color: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReaderScreen(
                          repository: repository,
                          controller: controller,
                          chapter: lastChapter,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            foregroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.menu_book_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'متابعة القراءة',
                                  style: TextStyle(
                                    color: Color(0xFFDDF4E9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  lastChapter.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              _Heading(title: 'أذكار يومية', hint: 'وصول سريع'),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: repository.quickSections.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final section = repository.quickSections[index];
                    return SizedBox(
                      width: 142,
                      child: SectionCard(
                        section: section,
                        compact: true,
                        onTap: () => _openSection(context, section),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _Heading(
                title: 'جميع الأقسام',
                hint: '${repository.metadata.totalChapterCount} بابًا',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.crossAxisExtent >= 760 ? 3 : 2;
              return SliverGrid.builder(
                itemCount: repository.categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: columns == 3 ? 0.92 : 0.73,
                ),
                itemBuilder: (context, index) {
                  final section = repository.categories[index];
                  return SectionCard(
                    section: section,
                    onTap: () => _openSection(context, section),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(
          hint,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
