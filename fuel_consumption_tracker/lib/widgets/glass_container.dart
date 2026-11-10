import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? tint;
  final double borderOpacity;
  final Color? borderColor;
  final double shadowOpacity;
  final LinearGradient? overlayGradient;
  final VoidCallback? onTap;
  final Alignment? alignment;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.tint,
    this.borderOpacity = 0.25,
    this.borderColor,
    this.shadowOpacity = 0.15,
    this.overlayGradient,
    this.onTap,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseTint =
        tint ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0x22FFFFFF)
            : const Color(0x80FFFFFF));
    final effectiveBorderColor =
        borderColor ?? Colors.white.withValues(alpha: borderOpacity);
    final radius = borderRadius ?? BorderRadius.circular(20);

    final glass = ClipRRect(
      borderRadius: radius,
      child: Container(
        alignment: alignment,
        decoration: BoxDecoration(
          gradient:
              overlayGradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseTint, baseTint.withValues(alpha: 0.6)],
              ),
          borderRadius: radius,
          border: Border.all(color: effectiveBorderColor, width: 1.2),
        ),
        child: child,
      ),
    );

    final shadowed = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: shadowOpacity),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: glass,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: shadowed),
      );
    }

    return shadowed;
  }
}

class GradientBlobBackground extends StatelessWidget {
  final Widget child;
  final bool dense;

  const GradientBlobBackground({
    super.key,
    required this.child,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // The blobs are purely decorative and never change, so the whole
    // background is painted once into its own layer. Anything scrolling on top
    // of it then repaints independently instead of dirtying this gradient.
    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF0F172A),
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ]
                      : const [
                          Color(0xFFF8FAFC),
                          Color(0xFFF1F5F9),
                          Color(0xFFF8FAFC),
                          Color(0xFFF1F5F9),
                        ],
                ),
              ),
            ),
          ),
          ..._buildBlobs(context, isDark: isDark, dense: dense),
          child,
        ],
      ),
    );
  }

  List<Widget> _buildBlobs(
    BuildContext context, {
    required bool isDark,
    required bool dense,
  }) {
    final size = MediaQuery.of(context).size;
    final blobs = [
      _BlobSpec(
        top: size.height * (dense ? -0.05 : -0.08),
        left: size.width * (dense ? 0.25 : 0.15),
        size: size.width * (dense ? 0.45 : 0.5),
        color: isDark ? const Color(0x150D9488) : const Color(0x120D9488),
      ),
      _BlobSpec(
        top: size.height * 0.3,
        right: size.width * (dense ? 0.1 : 0.2),
        size: size.width * (dense ? 0.35 : 0.42),
        color: isDark ? const Color(0x12475569) : const Color(0x10475569),
      ),
      _BlobSpec(
        bottom: size.height * (dense ? -0.1 : -0.05),
        left: size.width * (dense ? 0.15 : 0.2),
        size: size.width * (dense ? 0.4 : 0.45),
        color: isDark ? const Color(0x10D97706) : const Color(0x0DD97706),
      ),
      _BlobSpec(
        bottom: size.height * 0.15,
        right: -size.width * 0.05,
        size: size.width * (dense ? 0.3 : 0.35),
        color: isDark ? const Color(0x0E0D9488) : const Color(0x0C0D9488),
      ),
    ];

    return blobs.map((spec) => _Blob(spec: spec)).toList();
  }
}

class _BlobSpec {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  const _BlobSpec({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });
}

class _Blob extends StatelessWidget {
  final _BlobSpec spec;

  const _Blob({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: spec.top,
      left: spec.left,
      right: spec.right,
      bottom: spec.bottom,
      child: IgnorePointer(
        child: Container(
          width: spec.size,
          height: spec.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                spec.color.withValues(alpha: 0.5),
                spec.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
