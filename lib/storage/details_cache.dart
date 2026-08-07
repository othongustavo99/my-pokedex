import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_details_model.dart';
import '../models/pokemon_stat_model.dart';

class DetailsCache {
  static const _prefix = 'details_';

  Future<void> save(String id, PokemonDetailsModel details) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'height': details.height,
      'weight': details.weight,
      'types': details.types,
      'abilities': details.abilities,
      'stats': details.stats
          .map((s) => {'name': s.name, 'value': s.value})
          .toList(),
    };
    await prefs.setString('$_prefix$id', jsonEncode(map));
  }

  Future<PokemonDetailsModel?> load(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$id');
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PokemonDetailsModel(
        height: json['height'] as int,
        weight: json['weight'] as int,
        types: List<String>.from(json['types'] as List),
        abilities: List<String>.from(json['abilities'] as List),
        stats: (json['stats'] as List)
            .map(
              (s) => PokemonStatModel(
                name: s['name'] as String,
                value: s['value'] as int,
              ),
            )
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }
}
