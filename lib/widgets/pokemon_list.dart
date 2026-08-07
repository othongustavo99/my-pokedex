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
  final bool isGrid;

  const PokemonList({
    super.key,
    required this.pokemons,
    required this.controller,
    required this.isLoadingMore,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum Pokémon encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: pokemons.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == pokemons.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final pokemon = pokemons[index];
          return PokemonCard(
            pokemon: pokemon,
            isGrid: true,
            onTap: () => onTap(pokemon),
            isFavorite: isFavorite(pokemon),
            onFavoriteTap: () => onFavoriteTap(pokemon),
          );
        },
      );
    }

    return ListView.builder(
      controller: controller,
      itemCount: pokemons.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == pokemons.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final pokemon = pokemons[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 30).clamp(0, 300)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: PokemonCard(
            pokemon: pokemon,
            onTap: () => onTap(pokemon),
            isFavorite: isFavorite(pokemon),
            onFavoriteTap: () => onFavoriteTap(pokemon),
          ),
        );
      },
    );
  }
}
