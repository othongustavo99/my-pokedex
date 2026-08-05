import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import '../models/pokemon_details_model.dart';

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
}
