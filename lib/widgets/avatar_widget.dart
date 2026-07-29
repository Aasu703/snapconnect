import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:snapconnect/core/utils/avatar_helper.dart';

/// Circular avatar widget that renders a photo when [imageUrl] is set,
/// falling back to initials on a deterministic background otherwise.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    this.colorHex,
    this.size = 36,
    this.fontSize,
    this.imageUrl,
  });

  final String name;
  final String? colorHex;
  final double size;
  final double? fontSize;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final color = colorHex != null
        ? AvatarHelper.colorFromHex(colorHex)
        : AvatarHelper.colorFromSeed(name);

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}
