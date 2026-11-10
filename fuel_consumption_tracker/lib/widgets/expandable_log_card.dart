import 'package:flutter/material.dart';

import '../models/fuel_log.dart';

/// A fuel log row that expands to reveal secondary metrics.
///
/// The reveal is driven by [AnimatedSize] rather than a manual height
/// animation, so the card grows into whatever its content actually measures
/// (long notes, larger text scale) instead of guessing a pixel height.
class ExpandableLogCard extends StatefulWidget {
  const ExpandableLogCard({
    super.key,
    required this.log,
    this.startExpanded = false,
    this.costPerKm,
    this.mileage,
    this.notes,
    this.onTap,
  });

  final FuelLog log;

  /// Lets a parent restore state (e.g. a deep link reopening a log).
  final bool startExpanded;

  /// Optional derived figures; when null the row is simply omitted.
  final double? costPerKm;
  final double? mileage;
  final String? notes;
  final VoidCallback? onTap;

  @override
  State<ExpandableLogCard> createState() => _ExpandableLogCardState();
}

class _ExpandableLogCardState extends State<ExpandableLogCard> {
  late bool _expanded = widget.startExpanded;

  @override
  void didUpdateWidget(covariant ExpandableLogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startExpanded != oldWidget.startExpanded) {
      _expanded = widget.startExpanded;
    }
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final log = widget.log;
    final hasDetails =
        widget.costPerKm != null || widget.mileage != null || widget.notes != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surface,
        border: Border.all(
          color: _expanded
              ? scheme.primary.withValues(alpha: 0.45)
              : scheme.outlineVariant,
        ),
      ),
      child: Material(
        // Transparent so the AnimatedContainer gradient/border stays visible
        // while still providing an ink surface for the tap ripple.
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: hasDetails ? _toggle : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      log.isFullTank
                          ? Icons.local_gas_station_rounded
                          : Icons.timelapse_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.date,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      log.totalCost.toStringAsFixed(2),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Rotating the chevron in the same timebox as the size
                    // animation keeps the two reads as one gesture.
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.fuelVolume.toStringAsFixed(2)} L  •  '
                  '${log.odometer.toStringAsFixed(0)} km',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  // Prevents the child from being painted while fully
                  // collapsed, which avoids a one-frame layout of hidden text.
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: _Details(
                            log: log,
                            costPerKm: widget.costPerKm,
                            mileage: widget.mileage,
                            notes: widget.notes,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary content, kept separate so the collapsed state can drop it from
/// the tree entirely instead of leaving zero-height children around.
class _Details extends StatelessWidget {
  const _Details({
    required this.log,
    this.costPerKm,
    this.mileage,
    this.notes,
  });

  final FuelLog log;
  final double? costPerKm;
  final double? mileage;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 12),
        if (costPerKm != null)
          _DetailRow(
            icon: Icons.currency_rupee_rounded,
            label: 'Cost per km',
            value: costPerKm!.toStringAsFixed(2),
          ),
        if (mileage != null)
          _DetailRow(
            icon: Icons.speed_rounded,
            label: 'Mileage',
            value: '${mileage!.toStringAsFixed(2)} km/L',
          ),
        _DetailRow(
          icon: Icons.emoji_events_outlined,
          label: 'Tank status',
          value: log.isFullTank ? 'Full tank' : 'Partial fill',
        ),
        if (notes != null && notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            notes!.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
