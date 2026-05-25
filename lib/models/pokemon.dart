class Pokemon {
  final int id;
  final String name;
  final String urlImage;

  Pokemon({
    required this.id,
    required this.name,
    required this.urlImage,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      urlImage: json['sprites']['front_default'],
    );
  }
}