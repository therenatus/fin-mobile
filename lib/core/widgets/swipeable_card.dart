import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_feedback.dart';
import '../utils/page_transitions.dart';

/// Action configuration for swipeable card
class SwipeAction {
  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SwipeAction({
    required this.icon,
    this.label,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.onTap,
    this.isDestructive = false,
  });
}

/// Card with swipe actions (left/right)
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;
  final double actionWidth;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SwipeableCard({
    super.key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.actionWidth = 72,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;
  bool _isDragging = false;
  VoidCallback? _animationListener;

  double get _maxLeftDrag =>
      widget.leftActions != null ? widget.leftActions!.length * widget.actionWidth : 0;
  double get _maxRightDrag =>
      widget.rightActions != null ? widget.rightActions!.length * widget.actionWidth : 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );
  }

  @override
  void dispose() {
    if (_animationListener != null) {
      _controller.removeListener(_animationListener!);
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_isDragging) return;

    setState(() {
      _dragExtent += details.primaryDelta ?? 0;

      // Limit drag extent
      if (_dragExtent > 0 && widget.leftActions != null) {
        _dragExtent = _dragExtent.clamp(0, _maxLeftDrag);
      } else if (_dragExtent < 0 && widget.rightActions != null) {
        _dragExtent = _dragExtent.clamp(-_maxRightDrag, 0);
      } else if (_dragExtent > 0 && widget.leftActions == null) {
        _dragExtent = 0;
      } else if (_dragExtent < 0 && widget.rightActions == null) {
        _dragExtent = 0;
      }
    });

    // Haptic feedback at threshold
    if (_dragExtent.abs() == widget.actionWidth) {
      AppHaptics.swipeAction();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    _isDragging = false;

    // Snap to position or close
    final threshold = widget.actionWidth / 2;
    double targetExtent = 0;

    if (_dragExtent > threshold && widget.leftActions != null) {
      targetExtent = _maxLeftDrag;
    } else if (_dragExtent < -threshold && widget.rightActions != null) {
      targetExtent = -_maxRightDrag;
    }

    _animateToExtent(targetExtent);
  }

  void _animateToExtent(double target) {
    final startExtent = _dragExtent;
    _controller.reset();

    // Remove previous listener if exists
    if (_animationListener != null) {
      _controller.removeListener(_animationListener!);
    }

    _animationListener = () {
      setState(() {
        _dragExtent = startExtent + (_controller.value * (target - startExtent));
      });
    };

    _controller.addListener(_animationListener!);

    _controller.forward().then((_) {
      if (_animationListener != null) {
        _controller.removeListener(_animationListener!);
        _animationListener = null;
      }
    });
  }

  void close() {
    _animateToExtent(0);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(AppRadius.lg);

    return Container(
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Background actions
            Positioned.fill(
              child: Row(
                children: [
                  // Left actions
                  if (widget.leftActions != null && _dragExtent > 0)
                    _buildActions(widget.leftActions!, true),
                  const Spacer(),
                  // Right actions
                  if (widget.rightActions != null && _dragExtent < 0)
                    _buildActions(widget.rightActions!, false),
                ],
              ),
            ),
            // Main content
            GestureDetector(
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              onTap: () {
                if (_dragExtent != 0) {
                  close();
                } else {
                  widget.onTap?.call();
                }
              },
              onLongPress: widget.onLongPress,
              child: Transform.translate(
                offset: Offset(_dragExtent, 0),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(List<SwipeAction> actions, bool isLeft) {
    return SizedBox(
      width: actions.length * widget.actionWidth,
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          // Reveal animation based on drag
          final actionThreshold = (index + 1) * widget.actionWidth;
          final isRevealed = _dragExtent.abs() >= actionThreshold * 0.5;

          return GestureDetector(
            onTap: () {
              AppHaptics.mediumTap();
              close();
              action.onTap?.call();
            },
            child: AnimatedContainer(
              duration: AnimationDurations.fast,
              width: widget.actionWidth,
              decoration: BoxDecoration(
                color: action.backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isRevealed ? 1.0 : 0.5,
                    duration: AnimationDurations.fast,
                    child: Icon(
                      action.icon,
                      color: action.foregroundColor,
                      size: 24,
                    ),
                  ),
                  if (action.label != null) ...[
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: isRevealed ? 1.0 : 0.0,
                      duration: AnimationDurations.fast,
                      child: Text(
                        action.label!,
                        style: AppTypography.labelSmall.copyWith(
                          color: action.foregroundColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Simple dismissible card for delete actions
class DismissibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismissed;
  final String? dismissText;
  final Color dismissColor;
  final IconData dismissIcon;
  final bool confirmDismiss;
  final String? confirmTitle;
  final String? confirmMessage;

  const DismissibleCard({
    super.key,
    required this.child,
    this.onDismissed,
    this.dismissText,
    this.dismissColor = AppColors.error,
    this.dismissIcon = Icons.delete_outline,
    this.confirmDismiss = true,
    this.confirmTitle,
    this.confirmMessage,
  });

  Future<bool?> _showConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(confirmTitle ?? context.l10n.confirmation),
        content: Text(confirmMessage ?? context.l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              AppHaptics.mediumTap();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      confirmDismiss: confirmDismiss
          ? (_) async {
              final result = await _showConfirmDialog(context);
              if (result == true) {
                AppHaptics.heavyTap();
              }
              return result;
            }
          : null,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: dismissColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dismissText ?? context.l10n.delete,
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(dismissIcon, color: Colors.white),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Card with animated reveal actions on tap
class RevealActionsCard extends StatefulWidget {
  final Widget child;
  final List<SwipeAction> actions;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const RevealActionsCard({
    super.key,
    required this.child,
    required this.actions,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<RevealActionsCard> createState() => _RevealActionsCardState();
}

class _RevealActionsCardState extends State<RevealActionsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    AppHaptics.lightTap();
    if (_isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionsWidth = widget.actions.length * 64.0;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(AppRadius.lg);

    return ClipRRect(
      borderRadius: borderRadius,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Actions background
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: actionsWidth * _slideAnimation.value,
                child: Row(
                  children: widget.actions.map((action) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          AppHaptics.mediumTap();
                          _toggle();
                          action.onTap?.call();
                        },
                        child: Container(
                          color: action.backgroundColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(action.icon, color: action.foregroundColor),
                              if (action.label != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  action.label!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: action.foregroundColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Main content
              Transform.translate(
                offset: Offset(-actionsWidth * _slideAnimation.value, 0),
                child: GestureDetector(
                  onTap: _isExpanded ? _toggle : widget.onTap,
                  onLongPress: _toggle,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
