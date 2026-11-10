import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final bool glass;

  const AnimatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.glass = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(20);
    final isDark = theme.brightness == Brightness.dark;

    final glassTint =
        color ?? (isDark ? const Color(0x1AFFFFFF) : const Color(0x80FFFFFF));

    final decorated = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glassTint, glassTint.withValues(alpha: 0.55)],
        ),
        borderRadius: radius,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    final shell = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: decorated,
    );

    if (onTap == null) return shell;

    return _PressableCard(
      radius: radius,
      animationDuration: animationDuration,
      onTap: onTap!,
      child: shell,
    );
  }
}

/// Scales its child on press. The [child] is passed straight through to the
/// [AnimatedBuilder] so the subtree is built once instead of on every frame of
/// the press animation.
class _PressableCard extends StatefulWidget {
  final BorderRadius radius;
  final Duration animationDuration;
  final VoidCallback onTap;
  final Widget child;

  const _PressableCard({
    required this.radius,
    required this.animationDuration,
    required this.onTap,
    required this.child,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _controller.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  void _forward() => _controller.forward();

  void _reverse() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        return Transform.scale(
          scale: 1 - 0.02 * t,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _forward(),
              onTapUp: (_) => _reverse(),
              onTapCancel: _reverse,
              borderRadius: radius,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Slides and fades its child in once, then removes itself from the tree so no
/// extra opacity/transform layers are retained afterwards.
///
/// Must be given a [Key] when placed inside a lazily built list so each item
/// animates once instead of restarting on every rebuild.
class AnimatedSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.15),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedSlideIn> createState() => _AnimatedSlideInState();
}

class _AnimatedSlideInState extends State<AnimatedSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration + widget.delay,
      vsync: this,
    )..addStatusListener(_onStatus);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(_delayFraction, 1, curve: widget.curve),
    );
    _offsetAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(curved);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7)),
    );
    _controller.forward();
  }

  double get _delayFraction {
    final total = (widget.duration + widget.delay).inMicroseconds;
    if (total <= 0) return 0;
    return (widget.delay.inMicroseconds / total).clamp(0.0, 0.9);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCompleted) return widget.child;
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }
}

/// Fades its child in once, then removes itself from the tree.
class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration + widget.delay,
      vsync: this,
    )..addStatusListener(_onStatus);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(_delayFraction, 1, curve: widget.curve),
      ),
    );
    _controller.forward();
  }

  double get _delayFraction {
    final total = (widget.duration + widget.delay).inMicroseconds;
    if (total <= 0) return 0;
    return (widget.delay.inMicroseconds / total).clamp(0.0, 0.9);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCompleted) return widget.child;
    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }
}

/// Staggered entrance used by the screens for their sections/cards.
///
/// Driven by a single shared controller, it only translates the child while
/// animating (translation does not need an offscreen buffer) and drops the
/// animation entirely once finished so scrolling never fights an active
/// ticker or a retained opacity layer.
class StaggeredEntrance extends StatefulWidget {
  final Animation<double> animation;
  final int index;
  final double step;
  final double span;
  final double distance;
  final Widget child;

  const StaggeredEntrance({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
    this.step = 0.12,
    this.span = 0.5,
    this.distance = 30,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  late Animation<double> _delayed;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _delayed = _buildAnimation();
    _delayed.addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(covariant StaggeredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.animation != widget.animation) {
      _delayed.removeStatusListener(_onStatus);
      _delayed = _buildAnimation();
      _delayed.addStatusListener(_onStatus);
      _done = false;
    }
  }

  Animation<double> _buildAnimation() {
    final start = (widget.index * widget.step).clamp(0.0, 0.6);
    final end = (start + widget.span).clamp(0.4, 1.0);
    return widget.animation.drive(
      CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic)),
    );
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _done = true);
    }
  }

  @override
  void dispose() {
    _delayed.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return AnimatedBuilder(
      animation: _delayed,
      child: widget.child,
      builder: (context, child) {
        final t = _delayed.value;
        return Transform.translate(
          offset: Offset(0, widget.distance * (1 - t)),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
    );
  }
}
