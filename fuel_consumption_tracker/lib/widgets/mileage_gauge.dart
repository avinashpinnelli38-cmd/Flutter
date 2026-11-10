import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A speedometer-style semicircular gauge that visualises the core metric of
/// the app: fuel efficiency (km/L). Each make the gauge inpainter does:
/// a calm track arc, a gradient value arc, tick marks, an animated needle,
/// and the current value readout in the centre.
class MileageGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final String unit;
  final String? caption;
  final double width;
  final double height;
  final Color? trackColor;
  final Color? arcColor;
  final bool interactiveHint;

  const MileageGauge({
    super.key,
    required this.value,
    required this.maxValue,
    this.unit = 'km/L',
    this.caption,
    this.width = 220,
    this.height = 168,
    this.trackColor,
    this.arcColor,
    this.interactiveHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxValue <= 0 ? 1.0 : maxValue;
    final fraction = (value / effectiveMax).clamp(0.0, 1.0);

    // The readouts never change while the needle sweeps, so they are laid out
    // once here and handed to the painter instead of being re-shaped on every
    // frame of the animation.
    final valueColor = Theme.of(context).colorScheme.onSurface;
    final valuePainter = _buildText(
      value.toStringAsFixed(1),
      const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.0,
      ),
      valueColor,
    );
    final unitPainter = _buildText(
      unit,
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.0,
      ),
      valueColor.withValues(alpha: 0.6),
    );
    final captionPainter = caption == null
        ? null
        : _buildText(
            caption!,
            const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              height: 1.2,
            ),
            valueColor.withValues(alpha: 0.55),
          );
    final hintPainter = interactiveHint
        ? _buildText(
            'Full-tank fills unlock your mileage',
            const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            valueColor.withValues(alpha: 0.45),
          )
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animatedFraction, _) {
        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _MileageGaugePainter(
              fraction: animatedFraction,
              valuePainter: valuePainter,
              unitPainter: unitPainter,
              captionPainter: captionPainter,
              hintPainter: hintPainter,
              trackColor:
                  trackColor ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x26FFFFFF)
                      : const Color(0x33000000)),
              arcColor: arcColor ?? Theme.of(context).colorScheme.primary,
              needleColor: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.9),
              tickColor: Theme.of(context).colorScheme.outlineVariant,
              valueColor: valueColor,
              accentColor: Theme.of(context).colorScheme.secondary,
              tertiaryColor: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        );
      },
    );
  }

  static TextPainter _buildText(String text, TextStyle style, Color color) {
    return TextPainter(
      text: TextSpan(text: text, style: style.copyWith(color: color)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }
}

class _MileageGaugePainter extends CustomPainter {
  final double fraction;
  final TextPainter valuePainter;
  final TextPainter unitPainter;
  final TextPainter? captionPainter;
  final TextPainter? hintPainter;
  final Color trackColor;
  final Color arcColor;
  final Color needleColor;
  final Color tickColor;
  final Color valueColor;
  final Color accentColor;
  final Color tertiaryColor;

  _MileageGaugePainter({
    required this.fraction,
    required this.valuePainter,
    required this.unitPainter,
    required this.captionPainter,
    required this.hintPainter,
    required this.trackColor,
    required this.arcColor,
    required this.needleColor,
    required this.tickColor,
    required this.valueColor,
    required this.accentColor,
    required this.tertiaryColor,
  });

  static const double _sweep = math.pi / 2.0 * 2.0; // 180 degrees
  static const double _start = math.pi; // left, sweeping through bottom

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = math.min(size.width / 2 - 14, size.height - 34);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Track arc
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(arcRect, _start, _sweep, false, trackPaint);

    // Value arc with subtle gradient
    if (fraction > 0) {
      final sweep = _sweep * fraction.clamp(0.0, 1.0);
      final valuePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi * 2,
          colors: [Color(0xFFD97706), Color(0xFF0D9488), Color(0xFF475569)],
        ).createShader(Rect.fromCircle(center: center, radius: radius + 8));
      canvas.drawArc(arcRect, _start, sweep, false, valuePaint);
    }

    // Tick marks
    const ticks = 10;
    for (var i = 0; i <= ticks; i++) {
      final angle = _start + (_sweep * (i / ticks));
      final isMajor = i == 0 || i == ticks || i % 5 == 0;
      final outer = radius + (isMajor ? 13 : 10);
      final inner = outer - (isMajor ? 8 : 5);
      final startPoint =
          center + Offset(math.cos(angle), math.sin(angle)) * inner;
      final endPoint =
          center + Offset(math.cos(angle), math.sin(angle)) * outer;
      final tickPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMajor ? 2 : 1
        ..strokeCap = StrokeCap.round
        ..color = tickColor;
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // Needle
    final needleAngle = _start + (_sweep * fraction.clamp(0.0, 1.0));
    final needleLength = radius - 24;
    final needleEnd =
        center +
        Offset(math.cos(needleAngle), math.sin(needleAngle)) * needleLength;
    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = needleColor;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Hub
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..shader = RadialGradient(colors: [accentColor, arcColor])
            .createShader(Rect.fromCircle(center: center, radius: 8)),
    );
    canvas.drawCircle(
      center,
      2.8,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Readout text
    final middleY = center.dy - radius * 0.52;

    valuePainter.paint(
      canvas,
      Offset(size.width / 2 - valuePainter.width / 2, middleY),
    );
    unitPainter.paint(
      canvas,
      Offset(size.width / 2 - unitPainter.width / 2, middleY + 30),
    );

    final caption = captionPainter;
    if (caption != null) {
      caption.paint(canvas, Offset(size.width / 2 - caption.width / 2, middleY + 46));
    }

    final hint = hintPainter;
    if (hint != null) {
      hint.paint(canvas, Offset(size.width / 2 - hint.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _MileageGaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
