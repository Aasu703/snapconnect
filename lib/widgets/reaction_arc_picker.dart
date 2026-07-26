import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fan of emoji chips arced above a long-press point (Snapchat/iMessage-style
/// tapback picker). Purely presentational — [ReactionArcPicker.layout] does
/// the geometry so callers can hit-test drag position against the same
/// positions this widget renders at.
class ReactionArcPicker extends StatelessWidget {
  const ReactionArcPicker({
    super.key,
    required this.origin,
    required this.emojis,
    required this.hoverIndex,
    required this.screenSize,
  });

  final Offset origin;
  final List<String> emojis;
  final int? hoverIndex;
  final Size screenSize;

  static const double radius = 80;
  static const double liftAbove = 64;
  static const double chipSize = 48;
  static const double chipSizeHovered = 64;

  /// Computes the on-screen center of each emoji chip for the given touch
  /// [origin], clamped so the arc stays fully on-screen.
  static List<Offset> layout(Offset origin, int count, Size screenSize) {
    final margin = radius + chipSizeHovered / 2 + 8;
    final center = Offset(
      origin.dx.clamp(margin, screenSize.width - margin),
      (origin.dy - liftAbove).clamp(margin, screenSize.height - margin),
    );

    if (count == 1) {
      return [center + const Offset(0, -radius)];
    }

    const startDeg = 165.0;
    const endDeg = 15.0;
    final step = (startDeg - endDeg) / (count - 1);

    return List.generate(count, (i) {
      final rad = (startDeg - step * i) * math.pi / 180;
      return center + Offset(radius * math.cos(rad), -radius * math.sin(rad));
    });
  }

  /// Returns the index of the chip nearest [pointer], or null if the pointer
  /// has strayed too far from every chip (drag-to-cancel).
  static int? hitTest(
    Offset origin,
    Offset pointer,
    int count,
    Size screenSize,
  ) {
    final positions = layout(origin, count, screenSize);
    var bestIndex = -1;
    var bestDistance = double.infinity;

    for (var i = 0; i < positions.length; i++) {
      final distance = (positions[i] - pointer).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    return bestDistance <= radius + 36 ? bestIndex : null;
  }

  @override
  Widget build(BuildContext context) {
    final positions = layout(origin, emojis.length, screenSize);

    return IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < emojis.length; i++)
            _ArcChip(
                  center: positions[i],
                  emoji: emojis[i],
                  isHovered: hoverIndex == i,
                )
                .animate()
                .fadeIn(duration: 140.ms, delay: (i * 18).ms)
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  duration: 180.ms,
                  delay: (i * 18).ms,
                  curve: Curves.easeOutBack,
                ),
        ],
      ),
    );
  }
}

class _ArcChip extends StatelessWidget {
  const _ArcChip({
    required this.center,
    required this.emoji,
    required this.isHovered,
  });

  final Offset center;
  final String emoji;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final size = isHovered
        ? ReactionArcPicker.chipSizeHovered
        : ReactionArcPicker.chipSize;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      left: center.dx - size / 2,
      top: center.dy - size / 2 - (isHovered ? 10 : 0),
      width: size,
      height: size,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isHovered ? 0.35 : 0.2),
              blurRadius: isHovered ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: isHovered
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: TextStyle(fontSize: isHovered ? 32 : 24)),
      ),
    );
  }
}
