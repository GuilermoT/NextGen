import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen_fantasy/core/theme/app_colors.dart';

class SobreTacticaScreen extends StatefulWidget {
  const SobreTacticaScreen({super.key});

  @override
  State<SobreTacticaScreen> createState() => _SobreTacticaScreenState();
}

class _SobreTacticaScreenState extends State<SobreTacticaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFlipped = false;
  bool _showClose = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showClose = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSobre() {
    if (!_isFlipped) {
      setState(() => _isFlipped = true);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value * math.pi;
                    final isFront = _animation.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isFront
                          ? _CardFront()
                          : _buildCardBack(context),
                    );
                  },
                ),
                const SizedBox(height: 40),
                if (!_isFlipped)
                  ElevatedButton(
                    onPressed: _openSobre,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 52),
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.backgroundDark,
                    ),
                    child: const Text(
                      'Abrir',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                if (_showClose) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                      side: const BorderSide(color: AppColors.borderColor),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    // Counter-rotate so the back face reads correctly during the flip
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        width: 280,
        height: 360,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('¡Bonus desbloqueado!', style: theme.titleMedium),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Doble puntuación para delanteros esta jornada',
                style: theme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'x2 DEL',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      width: 280,
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '?',
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.88,
                end: 1.12,
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
            'Sobre de Táctica',
            style: theme.titleMedium?.copyWith(color: AppColors.accentGold),
          ),
          const SizedBox(height: 6),
          Text('Jornada 32', style: theme.bodySmall),
        ],
      ),
    );
  }
}
