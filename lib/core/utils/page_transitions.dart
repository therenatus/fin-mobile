import 'package:flutter/material.dart';

/// Animation durations used throughout the app
class AnimationDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);
  static const slower = Duration(milliseconds: 500);
}

/// Animation curves used throughout the app
class AnimationCurves {
  static const defaultCurve = Curves.easeOutCubic;
  static const bounceCurve = Curves.elasticOut;
  static const sharpCurve = Curves.easeOutExpo;
  static const smoothCurve = Curves.easeInOutCubic;
}

/// Fade page transition - good for modal-like navigation
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: AnimationCurves.defaultCurve,
              ),
              child: child,
            );
          },
        );
}

/// Slide page transition - standard push navigation
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = direction.offset;
            const end = Offset.zero;
            final curve = CurvedAnimation(
              parent: animation,
              curve: AnimationCurves.defaultCurve,
            );

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(curve),
              child: child,
            );
          },
        );
}

enum SlideDirection {
  right,
  left,
  up,
  down;

  Offset get offset {
    switch (this) {
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, 1.0);
      case SlideDirection.down:
        return const Offset(0.0, -1.0);
    }
  }
}

/// Scale page transition - good for FAB actions or zoom-in effects
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Alignment alignment;

  ScalePageRoute({
    required this.page,
    this.alignment = Alignment.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: AnimationCurves.defaultCurve,
            );

            return ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
              alignment: alignment,
              child: FadeTransition(
                opacity: curve,
                child: child,
              ),
            );
          },
        );
}

/// Combined slide and fade transition - premium feel
class SlideAndFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlideAndFadePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.normal,
          reverseTransitionDuration: AnimationDurations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: AnimationCurves.defaultCurve,
            );

            // Smaller slide offset for subtler effect
            final slideOffset = Offset(
              direction.offset.dx * 0.3,
              direction.offset.dy * 0.3,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: slideOffset,
                end: Offset.zero,
              ).animate(curve),
              child: FadeTransition(
                opacity: curve,
                child: child,
              ),
            );
          },
        );
}

/// Shared axis transition - material design style
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisType type;

  SharedAxisPageRoute({
    required this.page,
    this.type = SharedAxisType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AnimationDurations.slow,
          reverseTransitionDuration: AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: AnimationCurves.smoothCurve,
            );

            return SharedAxisTransition(
              animation: curve,
              type: type,
              child: child,
            );
          },
        );
}

enum SharedAxisType { horizontal, vertical, scaled }

class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final SharedAxisType type;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.type,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SharedAxisType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case SharedAxisType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case SharedAxisType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// Navigation helper extension
extension NavigationExtensions on BuildContext {
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push<T>(FadePageRoute(page: page));
  }

  Future<T?> pushSlide<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return Navigator.of(this).push<T>(SlidePageRoute(page: page, direction: direction));
  }

  Future<T?> pushScale<T>(Widget page, {Alignment alignment = Alignment.center}) {
    return Navigator.of(this).push<T>(ScalePageRoute(page: page, alignment: alignment));
  }

  Future<T?> pushSlideAndFade<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return Navigator.of(this).push<T>(SlideAndFadePageRoute(page: page, direction: direction));
  }

  Future<T?> pushSharedAxis<T>(Widget page, {SharedAxisType type = SharedAxisType.horizontal}) {
    return Navigator.of(this).push<T>(SharedAxisPageRoute(page: page, type: type));
  }
}

/// Staggered animation controller for list items
class StaggeredAnimationController {
  final int itemCount;
  final Duration itemDelay;
  final Duration itemDuration;

  StaggeredAnimationController({
    required this.itemCount,
    this.itemDelay = const Duration(milliseconds: 50),
    this.itemDuration = AnimationDurations.normal,
  });

  Duration getDelayForIndex(int index) {
    return Duration(milliseconds: itemDelay.inMilliseconds * index);
  }

  Duration get totalDuration {
    return Duration(
      milliseconds: itemDelay.inMilliseconds * (itemCount - 1) + itemDuration.inMilliseconds,
    );
  }
}

/// Widget for animating list items with staggered animation
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = AnimationDurations.normal,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.defaultCurve,
    );

    _offset = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.defaultCurve,
    ));

    // Start animation after staggered delay
    Future.delayed(
      Duration(milliseconds: widget.delay.inMilliseconds * widget.index),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}
