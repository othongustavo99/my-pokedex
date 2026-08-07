import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_model.dart';

class PokemonCache {
  static const _listKey = 'cached_pokemons';
  static const _timestampKey = 'cached_pokemons_at';

  /// Salva a lista de Pokémon no dispositivo.
  Future<void> savePokemons(List<PokemonModel> pokemons) async {
    final prefs = await SharedPreferences.getInstance();
    final data = pokemons.map((p) => {'name': p.name, 'url': p.url}).toList();
    await prefs.setString(_listKey, jsonEncode(data));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Lê a lista salva. Retorna vazia se não houver cache.
  Future<List<PokemonModel>> loadPokemons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (item) => PokemonModel(
              name: item['name'] as String,
              url: item['url'] as String,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Quando o cache foi salvo pela última vez (ou null).
  Future<DateTime?> lastCachedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_timestampKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<bool> hasCache() async {
    final list = await loadPokemons();
    return list.isNotEmpty;
  }
}
