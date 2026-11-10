import 'package:flutter/material.dart';

import 'glass_container.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBadges;

  const AuthScaffold({super.key, required this.child, this.showBadges = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        dense: false,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _AuthBrand(),
                    if (showBadges) ...[
                      const SizedBox(height: 12),
                      const _AuthBadges(),
                    ],
                    const SizedBox(height: 32),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D9488), Color(0xFF475569)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0x225A6B7B),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_gas_station_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D9488), Color(0xFF475569)],
          ).createShader(bounds),
          child: Text(
            'FuelTrail',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track mileage. Know your costs. Offline, private & simple.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AuthBadges extends StatelessWidget {
  const _AuthBadges();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: const [
          _FeatureBadge(icon: Icons.cloud_off_rounded, label: 'Offline'),
          _FeatureBadge(icon: Icons.lock_rounded, label: 'Private'),
          _FeatureBadge(icon: Icons.speed_rounded, label: 'Mileage'),
          _FeatureBadge(icon: Icons.currency_rupee_rounded, label: 'Costs'),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      borderOpacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
