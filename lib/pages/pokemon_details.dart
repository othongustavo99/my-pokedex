import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_details_model.dart';
import '../models/pokemon_model.dart';
import '../services/api_service.dart';
import '../utils/pokemon_colors.dart';
import '../widgets/error_view.dart';

class PokemonDetailsPage extends StatefulWidget {
  final PokemonModel pokemon;

  const PokemonDetailsPage({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonDetailsPage> createState() => _PokemonDetailsPageState();
}

class _PokemonDetailsPageState extends State<PokemonDetailsPage> {
  final ApiService _apiService = ApiService();

  PokemonDetailsModel? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getPokemonDetails(widget.pokemon.id);
      if (!mounted) return;
      setState(() {
        _details = result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível carregar os detalhes deste Pokémon.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _details == null
        ? Colors.grey
        : PokemonColors.getColor(_details!.types.first);

    return Scaffold(
      backgroundColor: primaryColor.withValues(alpha: 0.12),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.pokemon.displayName),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ErrorView(
              message: _errorMessage!,
              onRetry: _loadDetails,
            )
          : _buildContent(primaryColor),
    );
  }

  Widget _buildContent(Color primaryColor) {
    final details = _details!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 6),
                  color: Colors.black26,
                ),
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: widget.pokemon.image,
              width: 180,
              height: 180,
              placeholder: (context, url) => const SizedBox(
                width: 180,
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.pokemon.displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '#${widget.pokemon.id.padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Tipos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: details.types.map((type) {
                      final color = PokemonColors.getColor(type);
                      return Chip(
                        label: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: color,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Altura e peso
          Card(
            child: ListTile(
              leading: const Icon(Icons.straighten),
              title: Text(
                'Altura: ${details.heightInMeters} m  ·  Peso: ${details.weightInKg} kg',
              ),
            ),
          ),

          // Habilidades
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(
                'Habilidades: ${details.abilities.map((a) => a[0].toUpperCase() + a.substring(1)).join(', ')}',
              ),
            ),
          ),

          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Status Base',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          ...details.stats.map((stat) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stat.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(stat.value.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (stat.value / 255).clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
