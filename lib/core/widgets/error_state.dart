import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import 'animated_button.dart';

/// Full screen error state with animated icon and retry button
class ErrorState extends StatefulWidget {
  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool animate;

  const ErrorState({
    super.key,
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    this.icon,
    this.animate = true,
  });

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon ?? Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.message!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedElevatedButton(
                      label: widget.retryLabel ?? 'Повторить',
                      icon: Icons.refresh,
                      onPressed: widget.onRetry,
                      fullWidth: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline error banner for partial errors
class ErrorBanner extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.showRetry = true,
  });

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.defaultCurve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 50),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                widget.message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            if (widget.showRetry && widget.onRetry != null) ...[
              const SizedBox(width: AppSpacing.sm),
              AnimatedIconButton(
                icon: Icons.refresh,
                color: AppColors.error,
                onPressed: widget.onRetry,
                tooltip: 'Повторить',
              ),
            ],
            if (widget.onDismiss != null) ...[
              const SizedBox(width: AppSpacing.xs),
              AnimatedIconButton(
                icon: Icons.close,
                color: AppColors.error,
                onPressed: _dismiss,
                tooltip: 'Закрыть',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error state with connection icon
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off_rounded,
      title: 'Нет подключения',
      message: 'Проверьте подключение к интернету и повторите попытку',
      retryLabel: 'Повторить',
      onRetry: onRetry,
    );
  }
}

/// Server error state
class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ServerErrorState({super.key, this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.cloud_off_rounded,
      title: 'Ошибка сервера',
      message: message ?? 'Произошла ошибка на сервере. Попробуйте позже',
      retryLabel: 'Повторить',
      onRetry: onRetry,
    );
  }
}

/// Not found error state
class NotFoundState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const NotFoundState({
    super.key,
    this.title,
    this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.search_off_rounded,
      title: title ?? 'Не найдено',
      message: message ?? 'Запрашиваемые данные не найдены',
      retryLabel: actionLabel ?? 'Назад',
      onRetry: onAction ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Animated empty state with illustration
class AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _contentController;
  late Animation<double> _iconScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: AnimationDurations.slow,
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: AnimationCurves.defaultCurve,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: AnimationCurves.defaultCurve,
      ),
    );

    _iconController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _iconScale,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 56,
                  color: context.textTertiaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.h4.copyWith(
                        color: context.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.subtitle!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AnimatedElevatedButton(
                        label: widget.actionLabel!,
                        icon: Icons.add,
                        onPressed: widget.onAction,
                        fullWidth: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success state with checkmark animation
class SuccessState extends StatefulWidget {
  final String title;
  final String? message;
  final VoidCallback? onContinue;
  final String? continueLabel;

  const SuccessState({
    super.key,
    required this.title,
    this.message,
    this.onContinue,
    this.continueLabel,
  });

  @override
  State<SuccessState> createState() => _SuccessStateState();
}

class _SuccessStateState extends State<SuccessState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _checkAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _checkAnimation.value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedBuilder(
              animation: _contentAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _contentAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _contentAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.h4.copyWith(color: context.textPrimaryColor),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.message!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (widget.onContinue != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedElevatedButton(
                      label: widget.continueLabel ?? 'Продолжить',
                      onPressed: widget.onContinue,
                      fullWidth: false,
                      backgroundColor: AppColors.success,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
