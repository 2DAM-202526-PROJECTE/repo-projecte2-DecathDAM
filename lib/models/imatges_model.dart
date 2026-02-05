class Imatges {
  final String id;
  final String url;

  Imatges({required this.id, required this.url});

  factory Imatges.fromFirestore(String id, Map<String, dynamic> data) {
    return Imatges(id: id, url: data['url'] ?? data['uri'] ?? '');
  }
}
