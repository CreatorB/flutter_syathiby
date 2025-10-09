import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:syathiby/utils/extension/color.dart';

class CustomAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final Color? color;

  const CustomAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => AdvancedAvatar(
          name: name,
          size: size,
          autoTextSize: true,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? context.colorPrimary,
          ),
        ),
        placeholder: (context, url) => AdvancedAvatar(
          name: name,
          size: size,
          autoTextSize: true,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? context.colorPrimary,
          ),
        ),
      ),
    );
  }
}
