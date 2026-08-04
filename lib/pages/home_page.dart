import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../widgets/error_view.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  List<PokemonModel> _pokemons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getPokemons();
      if (!mounted) return;
      setState(() {
        _pokemons = result;
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

  void _openDetails(PokemonModel pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonDetailsPage(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ErrorView(
              message: _errorMessage!,
              onRetry: _loadPokemons,
            )
          : ListView.builder(
              itemCount: _pokemons.length,
              itemBuilder: (context, index) {
                final pokemon = _pokemons[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => _openDetails(pokemon),
                );
              },
            ),
    );
  }
}
