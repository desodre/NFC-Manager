class TagResult {
  const TagResult({
    required this.type,
    required this.capacity,
    required this.writable,
    required this.records,
  });

  final String type;
  final int capacity;
  final bool writable;
  final List<String> records;
}
