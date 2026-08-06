import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_details_model.dart';
import '../models/pokemon_model.dart';
import '../models/pokemon_evolution_model.dart';
import '../services/api_service.dart';
import '../utils/pokemon_colors.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer.dart';

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
  List<PokemonEvolutionModel> _evolutions = [];
  bool _isLoading = true;
  bool _isLoadingEvolutions = false;
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

      _loadEvolutions();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível carregar os detalhes deste Pokémon.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvolutions() async {
    setState(() => _isLoadingEvolutions = true);

    try {
      final evolutions = await _apiService.getEvolutionChain(widget.pokemon.id);
      if (!mounted) return;
      setState(() {
        _evolutions = evolutions;
        _isLoadingEvolutions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingEvolutions = false);
    }
  }

  Color _getStatColor(int value) {
    if (value < 50) return Colors.red;
    if (value < 80) return Colors.orange;
    if (value < 110) return Colors.amber.shade700;
    return Colors.green;
  }

  int get _totalStats {
    if (_details == null) return 0;
    return _details!.stats.fold(0, (sum, s) => sum + s.value);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _details == null
        ? Colors.grey.shade400
        : PokemonColors.getColor(_details!.types.first);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const PokemonDetailsSkeleton()
          : _errorMessage != null
          ? Scaffold(
              appBar: AppBar(
                title: Text(widget.pokemon.displayName),
              ),
              body: ErrorView(
                message: _errorMessage!,
                onRetry: _loadDetails,
              ),
            )
          : _buildContent(primaryColor),
    );
  }

  Widget _buildContent(Color primaryColor) {
    final details = _details!;
    final topPadding = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          stretch: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.pokemon.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.85),
                        primaryColor.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  top: topPadding + 20,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 200,
                      color: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Hero(
                      tag: widget.pokemon.id,
                      child: CachedNetworkImage(
                        imageUrl: widget.pokemon.image,
                        height: 180,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Text(
                    '#${widget.pokemon.id.padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.35),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: details.types.map((type) {
                  final color = PokemonColors.getColor(type);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _InfoTile(
                      icon: Icons.height,
                      label: 'Altura',
                      value: '${details.heightInMeters} m',
                      color: primaryColor,
                    ),
                    const SizedBox(width: 10),
                    _InfoTile(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Peso',
                      value: '${details.weightInKg} kg',
                      color: primaryColor,
                    ),
                    const SizedBox(width: 10),
                    _InfoTile(
                      icon: Icons.bar_chart_rounded,
                      label: 'Total',
                      value: '$_totalStats',
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Habilidades',
                icon: Icons.flash_on_rounded,
                color: primaryColor,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: details.abilities.map((ability) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            ability[0].toUpperCase() + ability.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Status Base',
                icon: Icons.analytics_outlined,
                color: primaryColor,
                child: Column(
                  children: details.stats.map((stat) {
                    final color = _getStatColor(stat.value);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              stat.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${stat.value}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: (stat.value / 255).clamp(0.0, 1.0),
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(color),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Evoluções',
                icon: Icons.auto_awesome,
                color: primaryColor,
                child: _isLoadingEvolutions
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _evolutions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Sem evoluções conhecidas',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _evolutions.length,
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final evo = _evolutions[index];
                            final isCurrent = evo.id == widget.pokemon.id;

                            return GestureDetector(
                              onTap: isCurrent
                                  ? null
                                  : () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PokemonDetailsPage(
                                            pokemon: PokemonModel(
                                              name: evo.name,
                                              url:
                                                  'https://pokeapi.co/api/v2/pokemon/${evo.id}/',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 100,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? primaryColor.withValues(alpha: 0.12)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCurrent
                                        ? primaryColor
                                        : Colors.grey.shade200,
                                    width: isCurrent ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: evo.image,
                                      width: 64,
                                      height: 64,
                                      placeholder: (_, __) => const SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      evo.displayName,
                                      style: TextStyle(
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '#${evo.id.padLeft(3, '0')}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
