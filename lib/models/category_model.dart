class Category {
  final String id;
  final String nom;
  final int ordre;

  Category({
    required this.id,
    required this.nom,
    this.ordre = 0,
  });

  factory Category.fromFirestore(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      nom: data['nom'] ?? '',
      ordre: data['ordre'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'ordre': ordre,
    };
  }
}
