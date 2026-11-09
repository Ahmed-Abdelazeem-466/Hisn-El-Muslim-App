abstract final class ArabicText {
  static final RegExp _diacritics = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]',
  );

  static String normalize(String value) {
    return value
        .replaceAll(_diacritics, '')
        .replaceAll('ـ', '')
        .replaceAll(RegExp('[إأآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  static String excerpt(String text, String normalizedQuery) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 120) return compact;
    final index = normalize(compact).indexOf(normalizedQuery);
    if (index < 0) return '${compact.substring(0, 117)}…';
    final start = (index - 34).clamp(0, compact.length);
    final end = (start + 120).clamp(start, compact.length);
    return '${start > 0 ? '…' : ''}${compact.substring(start, end)}${end < compact.length ? '…' : ''}';
  }
}
