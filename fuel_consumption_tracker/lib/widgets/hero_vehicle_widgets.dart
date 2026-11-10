import 'package:flutter/material.dart';

/// Shared tag factory so the source and destination can never drift apart.
///
/// Hero matches flights by tag equality only, so a single builder is the
/// safest way to keep both ends in sync as `vehicleId` changes.
String vehicleHeroTag(int vehicleId) => 'vehicle-icon-$vehicleId';

/// The animated element that actually flies between routes.
///
/// Keeping the icon (not the whole tile) as the flight subject means the list
/// tile can keep its own chrome while only the glyph travels, which reads as
/// spatial continuity rather than a full-screen zoom.
class VehicleHeroBadge extends StatelessWidget {
  const VehicleHeroBadge({
    super.key,
    required this.vehicleId,
    this.size = 48,
    this.icon = Icons.directions_car_filled_rounded,
  });

  final int vehicleId;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Hero(
      tag: vehicleHeroTag(vehicleId),
      // Default material-interpolation reuses the source's shadow/elevation on
      // the way out and the destination's on the way in, so the badge appears
      // to lift off the list and settle into the header.
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      child: Material(
        // A Material is required for ink/shadow to paint correctly mid-flight
        // when the hero is detached from its original Scaffold.
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(size * 0.3),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, size: size * 0.55, color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

/// Source widget: a vehicle row whose badge flies into [VehicleHeroHeader].
///
/// Pair with a `MaterialPageRoute` (or `PageRouteBuilder`) so the Hero has a
/// full-screen route to transition between.
class HeroVehicleTile extends StatelessWidget {
  const HeroVehicleTile({
    super.key,
    required this.vehicleId,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final int vehicleId;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: VehicleHeroBadge(vehicleId: vehicleId),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Destination widget: the dashboard header that receives the flying badge.
class VehicleHeroHeader extends StatelessWidget {
  const VehicleHeroHeader({
    super.key,
    required this.vehicleId,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final int vehicleId;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Row(
        children: [
          VehicleHeroBadge(vehicleId: vehicleId, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
