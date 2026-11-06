/// Title-like lines from a cover, longest first, without price and ISBN noise.
List<String> searchQueriesFromRecognizedText(String recognized) {
  final lines = recognized
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) {
        final letters = RegExp(r'[A-Za-zА-Яа-яЁё]').allMatches(line).length;
        return letters >= 3 && line.length <= 80;
      })
      .toList();
  lines.sort((a, b) => b.length.compareTo(a.length));
  final queries = <String>[];
  for (final line in lines) {
    if (!queries.contains(line)) {
      queries.add(line);
    }
    if (queries.length == 3) {
      break;
    }
  }
  if (queries.isEmpty) {
    final fallback = searchQueryFromRecognizedText(recognized);
    if (fallback.length >= 3) {
      return [fallback];
    }
  }
  return queries;
}

/// Uses the longest non-trivial line as a search query.
String searchQueryFromRecognizedText(String recognized) {
  final lines = recognized
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.length >= 3)
      .toList();
  if (lines.isEmpty) {
    return recognized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  lines.sort((a, b) => b.length.compareTo(a.length));
  final query = lines.first;
  if (query.length <= 180) {
    return query;
  }
  return query.substring(0, 180).trim();
}

/// Title prefill when no remote candidate matches.
String titleFromRecognizedText(String recognized) {
  final query = searchQueryFromRecognizedText(recognized);
  if (query.length <= 200) {
    return query;
  }
  return query.substring(0, 200).trim();
}
