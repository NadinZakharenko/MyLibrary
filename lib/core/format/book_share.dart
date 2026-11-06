String bookShareText({
  required String title,
  required List<String> authors,
  required String sourceUrl,
}) {
  final names = [
    for (final author in authors)
      if (author.trim().isNotEmpty) author.trim(),
  ];
  final lines = [
    if (title.trim().isNotEmpty) title.trim(),
    if (names.isNotEmpty) names.join(', '),
    if (sourceUrl.trim().isNotEmpty) sourceUrl.trim(),
  ];
  return lines.join('\n');
}
