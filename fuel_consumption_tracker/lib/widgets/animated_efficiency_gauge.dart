import 'package:flutter/material.dart';

/// Circular gauge that animates from zero to a fuel-efficiency value, with the
/// centre label counting up in lockstep with the arc.
///
/// Everything is driven by a single [TweenAnimationBuilder] so the number and
/// the ring can never desync — both are reads of the same animated `t`.
class AnimatedEfficiencyGauge extends StatelessWidget {
  const AnimatedEfficiencyGauge({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 30,
    this.size = 160,
    this.strokeWidth = 12,
    this.unit = 'km/L',
    this.label = 'Efficiency',
    this.duration = const Duration(milliseconds: 1400),
    this.curve = Curves.easeOutCubic,
  });

  /// The efficiency figure to display. Clamped into `[min, max]`.
  final double value;
  final double min;
  final double max;
  final double size;
  final double strokeWidth;
  final String unit;
  final String label;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: min, end: value.clamp(min, max)),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        final span = max - min;
        final progress = span <= 0 ? 0.0 : ((animatedValue - min) / span).clamp(0.0, 1.0);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track underneath; the value arc is masked over the top of it.
              CircularProgressIndicator(
                value: 1,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                color: scheme.surfaceContainerHighest,
              ),
              // `valueColor` only accepts a Color, so a gradient ring needs a
              // ShaderMask: paint the arc white, then keep only the pixels
              // where the gradient is opaque (BlendMode.srcIn).
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => SweepGradient(
                  startAngle: -1.5708, // 12 o'clock
                  endAngle: 4.7124, // full turn
                  colors: [
                    scheme.tertiary,
                    scheme.primary,
                    scheme.tertiary,
                  ],
                  // Rotating the sweep with the value makes the gradient
                  // appear to travel as the arc grows.
                  transform: GradientRotation(progress * 6.28318),
                ).createShader(bounds),
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  color: Colors.white,
                ),
              ),
              // RepaintBoundary keeps the label off the animating ring's
              // layer, so the number doesn't re-render the whole stack.
              RepaintBoundary(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animatedValue.toStringAsFixed(1),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      unit,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
