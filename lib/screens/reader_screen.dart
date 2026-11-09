import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';
import '../models/hisn_models.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    required this.repository,
    required this.controller,
    required this.chapter,
    this.section,
  });

  final BookRepository repository;
  final AppController controller;
  final HisnChapter chapter;
  final HisnSection? section;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late HisnChapter _chapter;

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter;
    _savePosition();
  }

  void _savePosition() {
    widget.controller.saveReadingPosition(
      _chapter.id,
      _chapter.blocks.isEmpty ? null : _chapter.blocks.first.id,
    );
  }

  void _openChapter(HisnChapter? chapter) {
    if (chapter == null) return;
    setState(() => _chapter = chapter);
    _savePosition();
    PrimaryScrollController.maybeOf(context)?.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final neighbors = widget.repository.neighbors(_chapter, widget.section);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.section?.title ?? 'حصن المسلم',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _chapter.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تصغير الخط',
            onPressed: widget.controller.decreaseFontSize,
            icon: const Text(
              'ع−',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'تكبير الخط',
            onPressed: widget.controller.increaseFontSize,
            icon: const Text(
              'ع+',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return ListView.builder(
            primary: true,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: _chapter.blocks.length + 1,
            itemBuilder: (context, index) {
              if (index == _chapter.blocks.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: neighbors.next == null
                              ? null
                              : () => _openChapter(neighbors.next),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('التالي'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: neighbors.previous == null
                              ? null
                              : () => _openChapter(neighbors.previous),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('السابق'),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final block = _chapter.blocks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (block.count > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'يُقال ${block.count} مرات',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              '${index + 1} / ${_chapter.blocks.length}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SelectableText(
                          block.text,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: widget.controller.readerFontSize,
                            height: 1.82,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (block.reference.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          SelectableText(
                            block.reference,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.65,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
