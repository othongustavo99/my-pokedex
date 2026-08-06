class PokemonEvolutionModel {
  final String id;
  final String name;
  final String image;

  const PokemonEvolutionModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory PokemonEvolutionModel.fromSpecies({
    required String name,
    required String speciesUrl,
  }) {
    // Extrai o ID da URL: https://pokeapi.co/api/v2/pokemon-species/25/
    final segments = Uri.parse(
      speciesUrl,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    final id = segments.isNotEmpty ? segments.last : '0';

    return PokemonEvolutionModel(
      id: id,
      name: name,
      image:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);
}
