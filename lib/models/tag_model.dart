class Tag {
  final String id;
  final String name;
  final String icon; // campo com o nome do ícone

  Tag({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Tag.fromMap(Map<String, dynamic> data, String documentId) {
    return Tag(
      id: documentId,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}