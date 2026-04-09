class Product {
  final String id;
  final String nom;
  final String descripcio;
  final double preu;
  final String categoria;
  final String url;
  final bool destacat;

  Product({
    required this.id,
    required this.nom,
    required this.descripcio,
    required this.preu,
    required this.categoria,
    required this.url,
    this.destacat = false,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nom: data['nom'] ?? '',
      descripcio: data['descripcio'] ?? '',
      preu: (data['preu'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? '',
      url: data['url'] ?? '',
      destacat: data['destacat'] ?? false,
    );
  }
}
