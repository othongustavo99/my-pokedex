import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../widgets/error_view.dart';
import 'pokemon_details.dart';
import '../widgets/search_bar.dart';
import '../widgets/pokemon_list.dart';
import 'favorites_page.dart';
import '../storage/favorites_storage.dart';
import '../widgets/shimmer.dart';
import '../widgets/type_filter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final FavoritesStorage _favoritesStorage = FavoritesStorage();
  bool _isSearching = false;
  String _currentQuery = '';
  String? _selectedType;
  List<PokemonModel> _typeFilteredPokemons = [];

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
    if (_selectedType != null || _currentQuery.isNotEmpty) return;

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

    // Busca os dados dos favoritos que ainda não temos em memória
    final List<PokemonModel> loadedFavorites = [];

    for (final id in ids) {
      // Já temos esse Pokémon na lista principal?
      final existing = _pokemons.where((p) => p.id == id).toList();
      if (existing.isNotEmpty) {
        loadedFavorites.add(existing.first);
        continue;
      }

      // Não tem → busca na API
      final pokemon = await _apiService.getPokemonById(id);
      if (pokemon != null) {
        loadedFavorites.add(pokemon);
      }
    }

    if (!mounted) return;

    setState(() {
      _favorites = loadedFavorites;
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
      _selectedType = null;
      _currentQuery = '';
      _typeFilteredPokemons = [];
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

  Future<void> _onTypeSelected(String? type) async {
    if (type == _selectedType) return;

    setState(() {
      _selectedType = type;
      _currentQuery = '';
      _isSearching = true;
      _errorMessage = null;
    });

    if (type == null) {
      setState(() {
        _typeFilteredPokemons = [];
        _filteredPokemons = List<PokemonModel>.from(_pokemons);
        _isSearching = false;
      });
      return;
    }

    try {
      final results = await _apiService.getPokemonsByType(type);
      if (!mounted) return;

      setState(() {
        _typeFilteredPokemons = results;
        _filteredPokemons = List<PokemonModel>.from(results);
        _isSearching = false;
      });
      _syncFavoritesFromPokemons(results);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _typeFilteredPokemons = [];
        _filteredPokemons = [];
        _isSearching = false;
        _errorMessage = 'Não foi possível filtrar por este tipo.';
      });
    }
  }

  Future<void> _filterPokemons(String query) async {
    _currentQuery = query.trim();

    final source = _selectedType != null ? _typeFilteredPokemons : _pokemons;

    if (_currentQuery.isEmpty) {
      setState(() {
        _filteredPokemons = List<PokemonModel>.from(source);
        _isSearching = false;
      });
      return;
    }

    final localResults = source.where((pokemon) {
      return pokemon.name.toLowerCase().contains(_currentQuery.toLowerCase());
    }).toList();

    if (localResults.isNotEmpty || _selectedType != null) {
      setState(() {
        _filteredPokemons = localResults;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _apiService.searchPokemon(_currentQuery);
      if (!mounted) return;
      setState(() {
        _filteredPokemons = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _filteredPokemons = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
        actions: [
          IconButton(
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
                if (mounted) setState(() {});
              });
            },
            icon: Badge(
              isLabelVisible: _favoriteIds.isNotEmpty,
              label: Text(
                _favoriteIds.length.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              child: const Icon(Icons.favorite),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const PokemonListSkeleton()
          : _errorMessage != null
          ? ErrorView(
              message: _errorMessage!,
              onRetry: _loadPokemons,
            )
          : Column(
              children: [
                PokemonSearchBar(onChanged: _filterPokemons),
                TypeFilterBar(
                  selectedType: _selectedType,
                  onTypeSelected: _onTypeSelected,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isSearching
                      ? const PokemonListSkeleton(itemCount: 6)
                      : RefreshIndicator(
                          onRefresh: () async {
                            _currentQuery = '';
                            _selectedType = null;
                            await _loadPokemons();
                          },
                          color: Colors.red,
                          child: PokemonList(
                            pokemons: _filteredPokemons,
                            controller: _scrollController,
                            isLoadingMore:
                                _isLoadingMore &&
                                _currentQuery.isEmpty &&
                                _selectedType == null,
                            onTap: _openDetails,
                            isFavorite: _isFavorite,
                            onFavoriteTap: _toggleFavorite,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
