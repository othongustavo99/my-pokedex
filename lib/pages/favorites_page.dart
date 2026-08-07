import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../widgets/pokemon_list.dart';

class FavoritesPage extends StatefulWidget {
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
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.favorites.isEmpty
              ? 'Favoritos'
              : 'Favoritos (${widget.favorites.length})',
        ),
        centerTitle: true,
      ),
      body: widget.favorites.isEmpty
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
              pokemons: widget.favorites,
              controller: _scrollController,
              isLoadingMore: false,
              onTap: widget.onPokemonTap,
              isFavorite: (_) => true,
              onFavoriteTap: widget.onFavoriteTap,
            ),
    );
  }
}
