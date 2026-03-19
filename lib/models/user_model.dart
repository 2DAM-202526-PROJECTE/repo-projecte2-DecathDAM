class UserModel {
  final String id;
  final String nom;
  final String email;
  final String rol; // "admin" o "client"
  final bool actiu;
  final String adreca;
  final String telefon;
  final String dni;
  final String dataNaixement;
  final String genere;
  final String codiPostal;
  final String ciutat;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.rol,
    required this.actiu,
    this.adreca = '',
    this.telefon = '',
    this.dni = '',
    this.dataNaixement = '',
    this.genere = '',
    this.codiPostal = '',
    this.ciutat = '',
  });

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'client',
      actiu: data['actiu'] ?? true,
      adreca: data['adreca'] ?? '',
      telefon: data['telefon'] ?? '',
      dni: data['dni'] ?? '',
      dataNaixement: data['dataNaixement'] ?? '',
      genere: data['genere'] ?? '',
      codiPostal: data['codiPostal'] ?? '',
      ciutat: data['ciutat'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'rol': rol,
      'actiu': actiu,
      'adreca': adreca,
      'telefon': telefon,
      'dni': dni,
      'dataNaixement': dataNaixement,
      'genere': genere,
      'codiPostal': codiPostal,
      'ciutat': ciutat,
    };
  }
}
