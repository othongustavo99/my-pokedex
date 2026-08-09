import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import '../models/pokemon_details_model.dart';
import '../models/pokemon_evolution_model.dart';

class ApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<PokemonModel>> getPokemons({
    int offset = 0,
    int limit = 20,
  }) async {
    final response = await http
        .get(
          Uri.parse(
            '$_baseUrl?offset=$offset&limit=$limit',
          ),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;

      return results
          .map(
            (pokemon) => PokemonModel.fromJson(pokemon as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('Erro ao carregar Pokémon (${response.statusCode})');
  }

  Future<PokemonDetailsModel> getPokemonDetails(String id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/$id'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PokemonDetailsModel.fromJson(data);
    }

    throw Exception('Erro ao carregar detalhes (${response.statusCode})');
  }

  Future<List<PokemonEvolutionModel>> getEvolutionChain(String id) async {
    final speciesResponse = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'))
        .timeout(_timeout);

    if (speciesResponse.statusCode != 200) {
      throw Exception('Erro ao buscar espécie');
    }

    final speciesData = jsonDecode(speciesResponse.body);
    final evolutionUrl = speciesData['evolution_chain']['url'] as String;

    final evolutionResponse = await http
        .get(Uri.parse(evolutionUrl))
        .timeout(_timeout);

    if (evolutionResponse.statusCode != 200) {
      throw Exception('Erro ao buscar evoluções');
    }

    final evolutionData = jsonDecode(evolutionResponse.body);
    final List<PokemonEvolutionModel> evolutions = [];

    void parse(dynamic chain) {
      final species = chain['species'];
      evolutions.add(
        PokemonEvolutionModel.fromSpecies(
          name: species['name'] as String,
          speciesUrl: species['url'] as String,
        ),
      );

      final evolvesTo = chain['evolves_to'] as List;
      for (final evo in evolvesTo) {
        parse(evo);
      }
    }

    parse(evolutionData['chain']);
    return evolutions;
  }

  Future<List<PokemonModel>> searchPokemon(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await http
        .get(Uri.parse('$_baseUrl/${query.toLowerCase().trim()}'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return [
        PokemonModel(
          name: data['name'] as String,
          url: '$_baseUrl/${data['id']}/',
        ),
      ];
    }

    return [];
  }

  Future<PokemonModel?> getPokemonById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$id'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PokemonModel(
          name: data['name'] as String,
          url: '$_baseUrl/$id/',
        );
      }
    } catch (_) {}
    return null;
  }

  Future<List<PokemonModel>> getPokemonsByType(String type) async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/type/${type.toLowerCase()}'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao filtrar por tipo (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final pokemonList = data['pokemon'] as List;

    return pokemonList.map((entry) {
      final pokemon = entry['pokemon'] as Map<String, dynamic>;
      return PokemonModel(
        name: pokemon['name'] as String,
        url: pokemon['url'] as String,
      );
    }).toList();
  }
}
