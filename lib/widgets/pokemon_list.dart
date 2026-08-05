import 'package:flutter/material.dart';

import '../models/pokemon_model.dart';
import 'pokemon_card.dart';

class PokemonList extends StatelessWidget {
  final List<PokemonModel> pokemons;
  final ScrollController controller;
  final bool isLoadingMore;
  final ValueChanged<PokemonModel> onTap;
  final bool Function(PokemonModel) isFavorite;
  final ValueChanged<PokemonModel> onFavoriteTap;

  const PokemonList({
    super.key,
    required this.pokemons,
    required this.controller,
    required this.isLoadingMore,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum Pokémon encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      itemCount: pokemons.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == pokemons.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final pokemon = pokemons[index];

        return PokemonCard(
          pokemon: pokemon,
          onTap: () => onTap(pokemon),

          isFavorite: isFavorite(pokemon),

          onFavoriteTap: () {
            onFavoriteTap(pokemon);
          },
        );
      },
    );
  }
}
