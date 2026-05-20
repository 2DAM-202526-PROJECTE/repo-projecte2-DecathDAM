class Product {
  final String id;
  final String nom;
  final String descripcio;
  final double preu;
  final String categoriaId;
  final String url;
  final bool destacat;
  final int descompte;

  Product({
    required this.id,
    required this.nom,
    required this.descripcio,
    required this.preu,
    required this.categoriaId,
    required this.url,
    this.destacat = false,
    this.descompte = 0,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nom: data['nom'] ?? '',
      descripcio: data['descripcio'] ?? '',
      preu: (data['preu'] ?? 0).toDouble(),
      // Suporta tant el camp nou 'categoriaId' com l'antic 'categoria'
      categoriaId: data['categoriaId'] ?? data['categoria'] ?? '',
      url: data['url'] ?? '',
      destacat: data['destacat'] ?? false,
      descompte: data['descompte'] ?? 0,
    );
  }
}
