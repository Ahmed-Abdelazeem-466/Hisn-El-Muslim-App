#!/usr/bin/env python3
"""Split combined navigation groups without changing the original Arabic content."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET = ROOT / 'assets/data/hisn-book.json'


def chapter_ids(numbers):
    return [f'chapter-{number:03d}' for number in numbers]


def section(id_, title, description, icon, color, numbers):
    return dict(id=id_, title=title, description=description, icon=icon,
                color=color, chapterIds=chapter_ids(numbers))


def main():
    data = json.loads(ASSET.read_text())
    before = [{k: v for k, v in ch.items() if k != 'categoryId'} for ch in data['chapters']]
    replacements = {
        'daily': [
            section('daily-day', 'اليوم', 'الاستيقاظ واللباس والمنزل وأذكار الصباح', 'wb-sunny', '#D49A2A', [*range(1, 12), 27]),
            section('daily-night', 'الليلة', 'أذكار المساء والنوم والتقلب ليلًا والأحلام', 'bedtime', '#40517B', range(28, 33)),
        ],
        'family-health': [
            section('family', 'الأسرة', 'المولود والأولاد والزواج والحياة الزوجية', 'family-restroom', '#A45F72', [48, 49, 80, 81, 82]),
            section('illness', 'المرض', 'عيادة المريض والدعاء له ودعاء المريض', 'healing', '#3C7892', range(50, 53)),
            section('death', 'الوفاة', 'الاحتضار والتعزية والصلاة على الميت والقبور', 'local-florist', '#66766C', range(53, 62)),
        ],
        'weather-food': [
            section('weather', 'الطقس', 'أذكار الريح والرعد والمطر والاستسقاء والاستصحاء والهلال', 'water-drop', '#3C7892', range(62, 69)),
            section('food-fasting', 'الطعام والصيام', 'أذكار الطعام والضيف والصائم والفطر والثمر', 'restaurant', '#7C664B', range(69, 78)),
        ],
    }
    categories = []
    for old in data['categories']:
        categories.extend(replacements.get(old['id'], [old]))
    data['categories'] = categories
    assignment = {}
    for category in categories:
        for ch_id in category['chapterIds']:
            assert ch_id not in assignment, f'Duplicate chapter {ch_id}'
            assignment[ch_id] = category['id']
    assert set(assignment) == {ch['id'] for ch in data['chapters']}
    for ch in data['chapters']:
        ch['categoryId'] = assignment[ch['id']]
    assert before == [{k: v for k, v in ch.items() if k != 'categoryId'} for ch in data['chapters']]
    assert len(categories) == 13
    assert len(data['chapters']) == 135
    assert sum(len(ch['blocks']) for ch in data['chapters']) == 320
    assert len({s['id'] for s in categories + data['quickSections']}) == len(categories) + len(data['quickSections'])
    ASSET.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    print('13 categories; 135 chapters / 320 blocks preserved. All navigation IDs are unique.')
    for cat in categories:
        print(cat['title'], len(cat['chapterIds']))


if __name__ == '__main__':
    main()
