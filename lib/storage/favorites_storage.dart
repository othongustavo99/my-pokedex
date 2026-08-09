import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const _key = 'favorite_pokemons';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites);
  }
}
