class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePictureUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePictureUrl,
  });

  /// Cria uma instância de [AppUser] a partir de um Map (normalmente do Firestore)
  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
    );
  }

  /// Converte uma instância de [AppUser] para um Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}