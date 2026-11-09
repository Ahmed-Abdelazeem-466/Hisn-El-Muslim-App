import 'package:flutter/material.dart';

import '../models/hisn_models.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.onTap,
    this.compact = false,
  });

  final HisnSection section;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = colorFromHex(section.color);
    return Semantics(
      button: true,
      label: 'فتح قسم ${section.title}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: compact ? 5 : 3,
                child: ColoredBox(
                  color: accent,
                  child: Stack(
                    children: [
                      if (section.eyebrow case final eyebrow?)
                        PositionedDirectional(
                          top: 10,
                          end: 12,
                          child: Text(
                            eyebrow,
                            style: const TextStyle(
                              color: Color(0xFFFFF8E7),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      Center(
                        child: Icon(
                          sectionIcon(section.icon),
                          size: compact ? 44 : 48,
                          color: const Color(0xFFFFF8E7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: compact ? 2 : 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 14,
                    vertical: compact ? 10 : 12,
                  ),
                  child: compact
                      ? Center(
                          child: Text(
                            section.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.35,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              section.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${section.chapterIds.length} بابًا',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color colorFromHex(String value) {
  final hex = value.replaceFirst('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

IconData sectionIcon(String name) {
  return switch (name) {
    'wb-sunny' => Icons.wb_sunny_rounded,
    'wb-twilight' => Icons.wb_twilight_rounded,
    'bedtime' => Icons.bedtime_rounded,
    'home' => Icons.home_rounded,
    'mosque' => Icons.mosque_rounded,
    'shield' => Icons.shield_rounded,
    'family-restroom' => Icons.family_restroom_rounded,
    'healing' => Icons.healing_rounded,
    'local-florist' => Icons.local_florist_rounded,
    'restaurant' => Icons.restaurant_rounded,
    'water-drop' => Icons.water_drop_rounded,
    'groups' => Icons.groups_rounded,
    'luggage' => Icons.luggage_rounded,
    'location-on' => Icons.location_on_rounded,
    'auto-stories' => Icons.auto_stories_rounded,
    _ => Icons.menu_book_rounded,
  };
}
