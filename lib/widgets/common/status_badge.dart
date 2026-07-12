// lib/widgets/common/status_badge.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppHelpers.getStatusColor(status);
    final isMenunggu = status.toLowerCase().contains('menunggu');

    final bgColor = isMenunggu ? const Color(0xF0FFFFFF) : baseColor.withOpacity(0.15);
    final borderCol = isMenunggu ? const Color(0xFF000000).withOpacity(0.3) : baseColor.withOpacity(0.4);
    final textCol = isMenunggu ? AppColors.primaryDark : baseColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
        border: Border.all(color: borderCol, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              width: large ? 8 : 6,
              height: large ? 8 : 6,
              decoration: BoxDecoration(
                color: textCol,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: textCol.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: large ? 6 : 4),
          ],
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: large ? 13 : 11,
              fontWeight: isMenunggu ? FontWeight.w700 : FontWeight.w600,
              color: textCol,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStatusBadge extends StatefulWidget {
  final String status;

  const AnimatedStatusBadge({super.key, required this.status});

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    final color = AppHelpers.getStatusColor(widget.status);
    final isMenunggu = widget.status.toLowerCase().contains('menunggu');
    final textCol = isMenunggu ? AppColors.primaryDark : color;
    final baseBg = isMenunggu ? Colors.white : color;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isMenunggu
                ? const Color(0xF0FFFFFF).withOpacity(_animation.value)
                : color.withOpacity(0.15 * _animation.value),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
            border: Border.all(
              color: isMenunggu
                  ? const Color(0xFF000000).withOpacity(0.3 * _animation.value)
                  : color.withOpacity(0.4 * _animation.value),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isMenunggu ? baseBg.withOpacity(_animation.value) : color.withOpacity(_animation.value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isMenunggu ? baseBg : color).withOpacity(0.5 * _animation.value),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.status,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isMenunggu ? FontWeight.w700 : FontWeight.w600,
                  color: textCol,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

