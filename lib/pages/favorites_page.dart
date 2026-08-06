import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../widgets/pokemon_list.dart';

class FavoritesPage extends StatelessWidget {
  final List<PokemonModel> favorites;
  final ValueChanged<PokemonModel> onFavoriteTap;
  final ValueChanged<PokemonModel> onPokemonTap;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onFavoriteTap,
    required this.onPokemonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          favorites.isEmpty ? 'Favoritos' : 'Favoritos (${favorites.length})',
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum Pokémon favorito ainda',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no coração para adicionar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : PokemonList(
              pokemons: favorites,
              controller: ScrollController(),
              isLoadingMore: false,
              onTap: onPokemonTap,
              isFavorite: (_) => true,
              onFavoriteTap: onFavoriteTap,
            ),
    );
  }
}
