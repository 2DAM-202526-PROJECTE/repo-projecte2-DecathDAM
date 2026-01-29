class Imatges {
  final String id;
  final String uri;


  Imatges({
    required this.id,
    required this.uri,
  });

  factory Imatges.fromFirestore(String id, Map<String, dynamic> data) {
    return Imatges(
      id: id,
      uri: data['uri'] ?? '',
    );
  }
}
