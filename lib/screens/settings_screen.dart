import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../data/book_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.repository,
    required this.controller,
  });

  final BookRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          key: const PageStorageKey('settings-scroll'),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            Text(
              'خصّص المظهر والقراءة بالطريقة الأنسب لك',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              title: 'مظهر التطبيق',
              icon: Icons.palette_rounded,
              child: SegmentedButton<ThemePreference>(
                segments: const [
                  ButtonSegment(
                    value: ThemePreference.system,
                    icon: Icon(Icons.brightness_auto_rounded),
                    label: Text('تلقائي'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    icon: Icon(Icons.light_mode_rounded),
                    label: Text('فاتح'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    icon: Icon(Icons.dark_mode_rounded),
                    label: Text('داكن'),
                  ),
                ],
                selected: {controller.themePreference},
                showSelectedIcon: false,
                onSelectionChanged: (values) =>
                    controller.setTheme(values.first),
              ),
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: 'حجم نص الأذكار',
              icon: Icons.format_size_rounded,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: controller.readerFontSize,
                        height: 1.65,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: controller.increaseFontSize,
                          child: const Text('تكبير'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${controller.readerFontSize.round()}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.decreaseFontSize,
                          child: const Text('تصغير'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: 'موضع القراءة',
              icon: Icons.bookmark_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.lastChapterId == null
                        ? 'لم يُحفظ موضع قراءة بعد.'
                        : 'يُحفظ آخر باب قرأته تلقائيًا لتتمكن من المتابعة من الفهرس.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  if (controller.lastChapterId != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.tonalIcon(
                        onPressed: controller.resetReadingPosition,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('إعادة ضبط موضع القراءة'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              title: 'عن الكتاب',
              icon: Icons.info_rounded,
              child: Text(
                '${repository.metadata.title} — ${repository.metadata.subtitle}\n'
                'تأليف ${repository.metadata.author}. يضم هذا الإصدار المحلي '
                '${repository.metadata.totalChapterCount} بابًا و'
                '${repository.metadata.totalBlockCount} مقطعًا، ويعمل دون اتصال بالإنترنت.',
                style: const TextStyle(height: 1.65),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
