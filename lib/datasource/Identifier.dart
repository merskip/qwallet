class Identifier<T> {
  final String domain;
  final String id;

  Identifier({
    required this.domain,
    required this.id,
  });

  static Identifier? tryParse(String string) {
    final parts = string.split(":");
    if (parts.length != 2) return null;
    return Identifier(domain: parts[0], id: parts[1]);
  }

  @override
  String toString() => [domain, id].join(":");
}
