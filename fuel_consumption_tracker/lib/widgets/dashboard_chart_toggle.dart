import 'package:flutter/material.dart';

/// Cross-fades between two dashboard visualizations.
///
/// `AnimatedCrossFade` drives both children from a single controller, so the
/// outgoing view fades out on the same clock the incoming one fades in — a
/// swap that would otherwise read as a hard cut.
class DashboardChartToggle extends StatefulWidget {
  const DashboardChartToggle({
    super.key,
    required this.showTrend,
    required this.trendView,
    required this.breakdownView,
    this.duration = const Duration(milliseconds: 400),
    this.sizeCurve = Curves.easeInOut,
    this.alignment = Alignment.topCenter,
    this.onToggle,
  });

  /// Which view is currently visible. `true` shows [trendView].
  final bool showTrend;
  final Widget trendView;
  final Widget breakdownView;

  final Duration duration;
  final Curve sizeCurve;
  final AlignmentGeometry alignment;

  /// Fired when the fade *settles*, not once per frame, so it is safe to use
  /// for logging or a follow-up request.
  final VoidCallback? onToggle;

  @override
  State<DashboardChartToggle> createState() => _DashboardChartToggleState();
}

class _DashboardChartToggleState extends State<DashboardChartToggle> {
  late bool _showTrend = widget.showTrend;

  @override
  void didUpdateWidget(covariant DashboardChartToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTrend != oldWidget.showTrend) {
      _showTrend = widget.showTrend;
    }
  }

  void _handleEnd() {
    if (mounted) widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: widget.duration,
      sizeCurve: widget.sizeCurve,
      alignment: widget.alignment,
      crossFadeState: _showTrend
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      // RepaintBoundary per child: the two charts are independent paint
      // trees, and without this the outgoing one's repaints are paid for by
      // the incoming one for the whole 400ms.
      firstChild: RepaintBoundary(child: widget.trendView),
      secondChild: RepaintBoundary(child: widget.breakdownView),
      onEnd: _handleEnd,
    );
  }
}

/// One segment of a segmented toggle that drives a [DashboardChartToggle].
///
/// Split out so the toggle itself stays purely presentational and can equally
/// be driven by a parent, a gesture, or a deep link.
class ChartToggleSegment extends StatelessWidget {
  const ChartToggleSegment({
    super.key,
    required this.value,
    required this.child,
    required this.onTap,
    this.tooltip,
  });

  final bool value;
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  static const Duration _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // A lift/press scale pairs the segment with the chart's 400ms cross-fade
    // without duplicating its timing.
    final pill = AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: value ? scheme.surface : Colors.transparent,
        boxShadow: value
            ? [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          size: 18,
          color: value ? scheme.primary : scheme.onSurfaceVariant,
        ),
        child: child,
      ),
    );

    return Semantics(
      button: true,
      selected: value,
      label: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: tooltip == null
              ? pill
              : Tooltip(message: tooltip!, child: pill),
        ),
      ),
    );
  }
}
