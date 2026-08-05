import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../widgets/error_view.dart';
import 'pokemon_details.dart';
import '../widgets/search_bar.dart';
import '../widgets/pokemon_list.dart';
import 'favorites_page.dart';
import '../storage/favorites_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final FavoritesStorage _favoritesStorage = FavoritesStorage();

  List<PokemonModel> _pokemons = [];
  List<PokemonModel> _filteredPokemons = [];

  /// IDs dos favoritos (fonte da verdade para persistência e checagem).
  final Set<String> _favoriteIds = {};

  /// Models dos favoritos que já conhecemos (para a página de favoritos).
  List<PokemonModel> _favorites = [];

  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  final int _limit = 20;

  bool _isLoadingMore = false;
  bool _hasMore = true;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  /// Carrega favoritos primeiro e depois a lista de Pokémon.
  Future<void> _init() async {
    await _loadFavorites();
    await _loadPokemons();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMorePokemons();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoritesStorage.getFavorites();
    if (!mounted) return;

    setState(() {
      _favoriteIds
        ..clear()
        ..addAll(ids);
    });
  }

  /// Sincroniza a lista de models favoritos com os Pokémon já carregados.
  void _syncFavoritesFromPokemons(List<PokemonModel> source) {
    for (final pokemon in source) {
      if (_favoriteIds.contains(pokemon.id) &&
          !_favorites.any((f) => f.id == pokemon.id)) {
        _favorites.add(pokemon);
      }
    }
  }

  Future<void> _toggleFavorite(PokemonModel pokemon) async {
    setState(() {
      if (_favoriteIds.contains(pokemon.id)) {
        _favoriteIds.remove(pokemon.id);
        _favorites.removeWhere((f) => f.id == pokemon.id);
      } else {
        _favoriteIds.add(pokemon.id);
        if (!_favorites.any((f) => f.id == pokemon.id)) {
          _favorites.add(pokemon);
        }
      }
    });

    await _favoritesStorage.saveFavorites(_favoriteIds.toList());
  }

  bool _isFavorite(PokemonModel pokemon) {
    return _favoriteIds.contains(pokemon.id);
  }

  Future<void> _loadPokemons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _offset = 0;
      _hasMore = true;
    });

    try {
      final result = await _apiService.getPokemons(
        offset: 0,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        _pokemons = result;
        _filteredPokemons = List<PokemonModel>.from(result);
        _syncFavoritesFromPokemons(result);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Não foi possível carregar os Pokémon.\nVerifique sua conexão e tente novamente.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _offset += _limit;

      final result = await _apiService.getPokemons(
        offset: _offset,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        if (result.isEmpty) {
          _hasMore = false;
        } else {
          _pokemons.addAll(result);
          // Mantém o filtro atual se houver busca ativa
          _filteredPokemons = List<PokemonModel>.from(_pokemons);
          _syncFavoritesFromPokemons(result);
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });

      debugPrint('Erro ao carregar mais Pokémon: $e');
    }
  }

  void _openDetails(PokemonModel pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailsPage(pokemon: pokemon),
      ),
    );
  }

  void _filterPokemons(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPokemons = List<PokemonModel>.from(_pokemons);
      } else {
        _filteredPokemons = _pokemons.where((pokemon) {
          return pokemon.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesPage(
                    favorites: List<PokemonModel>.from(_favorites),
                    onFavoriteTap: _toggleFavorite,
                    onPokemonTap: _openDetails,
                  ),
                ),
              ).then((_) {
                // Atualiza a UI ao voltar (caso tenha desfavoritado)
                if (mounted) setState(() {});
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ErrorView(
              message: _errorMessage!,
              onRetry: _loadPokemons,
            )
          : Column(
              children: [
                PokemonSearchBar(
                  onChanged: _filterPokemons,
                ),
                Expanded(
                  child: PokemonList(
                    pokemons: _filteredPokemons,
                    controller: _scrollController,
                    isLoadingMore: _isLoadingMore,
                    onTap: _openDetails,
                    isFavorite: _isFavorite,
                    onFavoriteTap: _toggleFavorite,
                  ),
                ),
              ],
            ),
    );
  }
}
