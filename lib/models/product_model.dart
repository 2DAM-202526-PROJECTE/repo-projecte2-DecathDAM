class Product {
  final String id;
  final String nom;
  final String descripcio;
  final double preu;
  final String imatge;
  final String categoria;
  final String url;

  Product({
    required this.id,
    required this.nom,
    required this.descripcio,
    required this.preu,
    required this.imatge,
    required this.categoria,
    required this.url,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nom: data['nom'] ?? '',
      descripcio: data['descripcio'] ?? '',
      preu: (data['preu'] ?? 0).toDouble(),
      imatge: data['imatge'] ?? '',
      categoria: data['categoria'] ?? '',
      url: data['url'] ?? '',
    );
  }
}
