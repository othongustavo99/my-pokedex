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
import '../main.dart';
import '../utils/page_transitions.dart';
import '../storage/pokemon_cache.dart';

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
  bool _isGrid = false;
  final PokemonCache _pokemonCache = PokemonCache();
  bool _isOffline = false; // true quando a lista veio do cache

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
      _isOffline = false;
    });

    try {
      final result = await _apiService.getPokemons(
        offset: 0,
        limit: _limit,
      );

      if (!mounted) return;

      // Salva no cache para uso offline
      await _pokemonCache.savePokemons(result);

      setState(() {
        _pokemons = result;
        _filteredPokemons = List<PokemonModel>.from(result);
        _syncFavoritesFromPokemons(result);
        _isLoading = false;
        _isOffline = false;
      });
    } catch (_) {
      // API falhou → tenta cache
      final cached = await _pokemonCache.loadPokemons();
      if (!mounted) return;

      if (cached.isNotEmpty) {
        setState(() {
          _pokemons = cached;
          _filteredPokemons = List<PokemonModel>.from(cached);
          _syncFavoritesFromPokemons(cached);
          _isLoading = false;
          _isOffline = true;
          _hasMore = false; // sem paginação offline
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Não foi possível carregar os Pokémon.\nVerifique sua conexão e tente novamente.';
          _isLoading = false;
          _isOffline = false;
        });
      }
    }
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoadingMore || !_hasMore || _isOffline) return;

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
          if (_currentQuery.isEmpty && _selectedType == null) {
            _filteredPokemons = List<PokemonModel>.from(_pokemons);
          }
          _syncFavoritesFromPokemons(result);
        }
        _isLoadingMore = false;
      });

      // Atualiza cache com a lista completa carregada
      await _pokemonCache.savePokemons(_pokemons);
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
      FadeSlidePageRoute(
        page: PokemonDetailsPage(pokemon: pokemon),
      ),
    );
  }

  Future<void> _onTypeSelected(String? type) async {
    if (type == _selectedType) return;
    if (_isOffline && type != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filtro por tipo precisa de internet'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
            tooltip: _isGrid ? 'Ver em lista' : 'Ver em grade',
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(
              _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                FadeSlidePageRoute(
                  page: FavoritesPage(
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
          IconButton(
            tooltip: 'Tema',
            onPressed: () {
              final app = PokedexApp.of(context);
              final current = app.themeMode;
              final next = switch (current) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
              app.setThemeMode(next);

              final label = switch (next) {
                ThemeMode.light => 'Claro',
                ThemeMode.dark => 'Escuro',
                ThemeMode.system => 'Sistema',
              };
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tema: $label'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              switch (PokedexApp.of(context).themeMode) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const PokemonListSkeleton()
          : Column(
              children: [
                if (_isOffline)
                  MaterialBanner(
                    content: const Text(
                      'Modo offline — mostrando dados salvos',
                      style: TextStyle(fontSize: 13),
                    ),
                    leading: const Icon(Icons.wifi_off, size: 20),
                    backgroundColor: Colors.orange.shade100,
                    actions: [
                      TextButton(
                        onPressed: _loadPokemons,
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ),
                // Busca e filtro ficam sempre visíveis (exceto no loading inicial)
                if (_errorMessage == null || _filteredPokemons.isNotEmpty) ...[
                  PokemonSearchBar(onChanged: _filterPokemons),
                  TypeFilterBar(
                    selectedType: _selectedType,
                    onTypeSelected: _onTypeSelected,
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: _errorMessage != null && _filteredPokemons.isEmpty
                      ? ErrorView(
                          message: _errorMessage!,
                          onRetry: () {
                            if (_selectedType != null) {
                              _onTypeSelected(_selectedType);
                            } else {
                              _loadPokemons();
                            }
                          },
                        )
                      : _isSearching
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
                            isGrid: _isGrid,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
