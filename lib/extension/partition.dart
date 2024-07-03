extension Partition<E> on List<E> {
  Iterable<List<E>> partition(int size) sync* {
    for (var i = 0; i < length; i += size) {
      yield sublist(i, i + size < length ? (i + size) : length);
    }
  }
}