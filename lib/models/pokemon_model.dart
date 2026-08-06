class PokemonModel {
  final String name;
  final String url;

  const PokemonModel({
    required this.name,
    required this.url,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Extrai o ID da URL da PokeAPI de forma segura.
  String get id {
    final segments = Uri.parse(
      url,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    return segments.isNotEmpty ? segments.last : '0';
  }

  String get image {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);
}
