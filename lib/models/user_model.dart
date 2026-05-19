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
  final String idioma;
  final String subscripcio;

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
    this.idioma = 'ca',
    this.subscripcio = 'Sense subscripció',
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
      idioma: data['idioma'] ?? 'ca',
      subscripcio: data['subscripcio'] ?? 'Sense subscripció',
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
      'idioma': idioma,
      'subscripcio': subscripcio,
    };
  }

  UserModel copyWith({
    String? nom,
    String? email,
    String? rol,
    bool? actiu,
    String? adreca,
    String? telefon,
    String? dni,
    String? dataNaixement,
    String? genere,
    String? codiPostal,
    String? ciutat,
    String? idioma,
    String? subscripcio,
  }) {
    return UserModel(
      id: id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      actiu: actiu ?? this.actiu,
      adreca: adreca ?? this.adreca,
      telefon: telefon ?? this.telefon,
      dni: dni ?? this.dni,
      dataNaixement: dataNaixement ?? this.dataNaixement,
      genere: genere ?? this.genere,
      codiPostal: codiPostal ?? this.codiPostal,
      ciutat: ciutat ?? this.ciutat,
      idioma: idioma ?? this.idioma,
      subscripcio: subscripcio ?? this.subscripcio,
    );
  }
}
