class PokemonStatModel {
  final String name;
  final int value;

  const PokemonStatModel({
    required this.name,
    required this.value,
  });

  factory PokemonStatModel.fromJson(Map<String, dynamic> json) {
    return PokemonStatModel(
      name: json['stat']['name'] as String,
      value: json['base_stat'] as int,
    );
  }

  String get displayName {
    return name
        .split('-')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
