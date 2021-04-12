extension IterableFinding<E> on Iterable<E> {
  E? get firstOrNull => isNotEmpty ? first : null;
  E? get lastOrNull => isNotEmpty ? last : null;

  E? findFirstOrNull(bool test(E element)) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? findLastOrNull(bool test(E element)) {
    E? last;
    for (final element in this) {
      if (test(element)) last = element;
    }
    return last;
  }
}

extension ListSplitting<T> on List<T> {
  List<List<T>> split(int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }
}

extension IterableOptional<E> on Iterable<E?> {
  List<E> filterNonNull() {
    final result = <E>[];
    for (final element in this) {
      if (element != null) result.add(element);
    }
    return result;
  }
}
