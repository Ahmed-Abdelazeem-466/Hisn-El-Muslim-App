import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';
import '../models/hisn_models.dart';
import 'reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
    required this.controller,
  });

  final BookRepository repository;
  final AppController controller;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<SearchResult> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() => _results = widget.repository.search(query));
  }

  @override
  Widget build(BuildContext context) {
    final queryReady = _controller.text.trim().length >= 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'البحث',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          Text(
            'ابحث في عناوين الأبواب ونصوص الأذكار والمراجع',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'اكتب كلمتين على الأقل',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح البحث',
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.cancel_rounded),
                    ),
            ),
          ),
          if (queryReady) ...[
            const SizedBox(height: 12),
            Text(
              _results.isEmpty
                  ? 'لا توجد نتائج مطابقة'
                  : '${_results.length} نتيجة',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _results.isEmpty
                ? _EmptySearch(hasQuery: queryReady)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          title: Text(
                            result.chapter.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              result.excerpt,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(height: 1.55),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_left_rounded),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ReaderScreen(
                                  repository: widget.repository,
                                  controller: widget.controller,
                                  chapter: result.chapter,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                hasQuery
                    ? Icons.search_off_rounded
                    : Icons.manage_search_rounded,
                color: muted,
                size: 31,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hasQuery ? 'جرّب كلمة أخرى' : 'ابحث بسهولة داخل الكتاب',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              hasQuery
                  ? 'يمكنك البحث بجزء من عنوان الباب أو كلمات من نص الذكر.'
                  : 'مثال: أذكار الصباح، السفر، الكرب، أو الاستغفار.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
