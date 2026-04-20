import 'package:flutter/material.dart';
import 'package:snapconnect/core/utils/avatar_helper.dart';

/// Circular avatar widget that renders initials and a deterministic background.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    this.colorHex,
    this.size = 36,
    this.fontSize,
  });

  final String name;
  final String? colorHex;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final color = colorHex != null
        ? AvatarHelper.colorFromHex(colorHex)
        : AvatarHelper.colorFromSeed(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        AvatarHelper.initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? size * 0.38,
        ),
      ),
    );
  }
}
