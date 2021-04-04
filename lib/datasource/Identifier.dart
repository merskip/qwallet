class Identifier<T> {
  final String domain;
  final String id;

  Identifier({
    required this.domain,
    required this.id,
  });

  static Identifier<T> parse<T>(String string) {
    final parts = string.split(":");
    if (parts.length != 2) throw Exception("Failed parse identifier");
    return Identifier(domain: parts[0], id: parts[1]);
  }

  static Identifier<T>? tryParse<T>(String string) {
    final parts = string.split(":");
    if (parts.length != 2) return null;
    return Identifier(domain: parts[0], id: parts[1]);
  }

  @override
  String toString() => [domain, id].join(":");
}
