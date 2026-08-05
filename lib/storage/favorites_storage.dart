import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const _key = 'favorite_pokemons';

  /// Retorna a lista de IDs favoritos (sempre como String).
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Salva a lista de IDs favoritos.
  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites);
  }
}