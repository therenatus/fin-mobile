import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmer effect widget for loading states
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? context.surfaceVariantColor;
    final highlightColor = widget.highlightColor ?? context.surfaceColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

/// Shimmer placeholder for rectangular content
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for circular content (avatars)
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Shimmer loading for card-style content
class ShimmerCard extends StatelessWidget {
  final double? height;

  const ShimmerCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        height: height ?? 120,
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for order cards
class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(context, 100, 16),
                _buildBox(context, 60, 24, borderRadius: AppRadius.full),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBox(context, 180, 20),
            const SizedBox(height: AppSpacing.sm),
            _buildBox(context, 140, 14),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(context, 80, 14),
                _buildBox(context, 100, 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, double width, double height, {double borderRadius = AppRadius.sm}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer loading placeholder for client cards
class ShimmerClientCard extends StatelessWidget {
  const ShimmerClientCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Shimmer(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBox(context, 150, 18),
                  const SizedBox(height: AppSpacing.xs),
                  _buildBox(context, 120, 14),
                ],
              ),
            ),
            _buildBox(context, 24, 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

/// Shimmer loading placeholder for stat cards
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(context, 100, 14),
                _buildBox(context, 32, 32, borderRadius: AppRadius.full),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBox(context, 80, 28),
            const SizedBox(height: AppSpacing.sm),
            _buildBox(context, 60, 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, double width, double height, {double borderRadius = AppRadius.sm}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer loading for a list of items
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final double spacing;
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = AppSpacing.md,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}

/// Shimmer loading for order list
class ShimmerOrderList extends StatelessWidget {
  final int itemCount;

  const ShimmerOrderList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: itemCount,
      itemBuilder: (_) => const ShimmerOrderCard(),
    );
  }
}

/// Shimmer loading for client list
class ShimmerClientList extends StatelessWidget {
  final int itemCount;

  const ShimmerClientList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: itemCount,
      itemBuilder: (_) => const ShimmerClientCard(),
    );
  }
}

/// Shimmer loading for stat grid
class ShimmerStatGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerStatGrid({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.3,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerStatCard(),
    );
  }
}

/// Shimmer loading for employee cards
class ShimmerEmployeeCard extends StatelessWidget {
  const ShimmerEmployeeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.borderColor),
      ),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.surfaceVariantColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBox(context, 140, 18),
                      const SizedBox(height: AppSpacing.xs),
                      _buildBox(context, 100, 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(context, 80, 14),
                _buildBox(context, 60, 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.surfaceVariantColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
