String? seriesLabel(String? name, int? volume) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty && volume == null) {
    return null;
  }
  if (trimmed.isEmpty) {
    return 'Том $volume';
  }
  if (volume == null) {
    return trimmed;
  }
  return '$trimmed, том $volume';
}
