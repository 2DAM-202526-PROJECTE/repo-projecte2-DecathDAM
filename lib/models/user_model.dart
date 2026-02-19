class UserModel {
  final String id;
  final String nom;
  final String email;
  final String rol; // "admin" o "client"
  final bool actiu;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.rol,
    required this.actiu,
  });

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'client',
      actiu: data['actiu'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'email': email, 'rol': rol, 'actiu': actiu};
  }
}
