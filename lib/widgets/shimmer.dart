import 'package:flutter/material.dart';

/// Animação de shimmer reutilizável (sem dependência externa).
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0),
              end: Alignment(1.0 - _controller.value * 2, 0),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Bloco cinza usado dentro do shimmer.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton de um card da lista de Pokémon.
class PokemonCardSkeleton extends StatelessWidget {
  const PokemonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Shimmer(
          child: Row(
            children: [
              const ShimmerBox(width: 72, height: 72, borderRadius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 48, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 120, height: 18, borderRadius: 4),
                  ],
                ),
              ),
              const ShimmerBox(width: 28, height: 28, borderRadius: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista de skeletons para o loading inicial / busca.
class PokemonListSkeleton extends StatelessWidget {
  final int itemCount;

  const PokemonListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const PokemonCardSkeleton(),
    );
  }
}

/// Skeleton da tela de detalhes.
class PokemonDetailsSkeleton extends StatelessWidget {
  const PokemonDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 90),
            const ShimmerBox(width: 160, height: 28, borderRadius: 6),
            const SizedBox(height: 8),
            const ShimmerBox(width: 60, height: 16, borderRadius: 4),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ShimmerBox(
                    width: double.infinity,
                    height: 90,
                    borderRadius: 16,
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 100,
                          borderRadius: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 100,
                          borderRadius: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 16,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ShimmerBox(width: 120, height: 22, borderRadius: 4),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    6,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 56,
                        borderRadius: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
