import 'pokemon_stat_model.dart';

class PokemonDetailsModel {
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStatModel> stats;

  const PokemonDetailsModel({
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
  });

  factory PokemonDetailsModel.fromJson(Map<String, dynamic> json) {
    return PokemonDetailsModel(
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((stat) => PokemonStatModel.fromJson(stat))
          .toList(),
    );
  }

  double get heightInMeters => height / 10;
  double get weightInKg => weight / 10;
}
