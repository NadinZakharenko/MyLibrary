/// Empty capacity is unlimited. Overfull means the count is strictly greater.
bool rowIsOverfull({required int bookCount, required int? capacity}) {
  final limit = capacity;
  if (limit == null) {
    return false;
  }
  return bookCount > limit;
}
