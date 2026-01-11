import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_feedback.dart';
import '../utils/page_transitions.dart';

/// Animated button with scale effect and haptic feedback
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final bool enableHaptic;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? splashColor;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.enableHaptic = true,
    this.duration = AnimationDurations.fast,
    this.borderRadius,
    this.splashColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _controller.forward();
    if (widget.enableHaptic) {
      AppHaptics.lightTap();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    _controller.reverse();
  }

  void _onTap() {
    widget.onPressed?.call();
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      if (widget.enableHaptic) {
        AppHaptics.longPress();
      }
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed != null ? _onTap : null,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Animated elevated button
class AnimatedElevatedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AnimatedElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: ElevatedButton(
        onPressed: widget.isLoading
            ? null
            : () {
                AppHaptics.lightTap();
                widget.onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
          minimumSize: widget.fullWidth ? const Size.fromHeight(52) : null,
        ),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(widget.label),
                  ],
                ),
        ),
      ),
    );

    return widget.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Animated icon button with scale effect
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconButton = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AppHaptics.lightTap();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: widget.backgroundColor != null
              ? BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                )
              : null,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? context.textPrimaryColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: iconButton,
      );
    }

    return iconButton;
  }
}

/// Animated FAB with scale animation
class AnimatedFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool extended;

  const AnimatedFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.extended = false,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AppHaptics.mediumTap();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: widget.extended && widget.label != null
            ? FloatingActionButton.extended(
                onPressed: null,
                backgroundColor: widget.backgroundColor ?? AppColors.primary,
                foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
                icon: Icon(widget.icon),
                label: Text(widget.label!),
              )
            : FloatingActionButton(
                onPressed: null,
                backgroundColor: widget.backgroundColor ?? AppColors.primary,
                foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
                child: Icon(widget.icon),
              ),
      ),
    );
  }
}

/// Animated chip with selection animation
class AnimatedChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const AnimatedChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
  });

  @override
  State<AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AppHaptics.selection();
        widget.onSelected?.call(!widget.selected);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: AnimatedContainer(
          duration: AnimationDurations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.icon != null ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.primary.withOpacity(0.1)
                : context.surfaceVariantColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: widget.selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.selected
                      ? AppColors.primary
                      : context.textSecondaryColor,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.selected
                      ? AppColors.primary
                      : context.textPrimaryColor,
                  fontWeight:
                      widget.selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bounce animation wrapper
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const BounceAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
