extension IterableFinding<E> on Iterable<E> {
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
