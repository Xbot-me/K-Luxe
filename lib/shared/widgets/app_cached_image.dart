import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth = 400,
    this.memCacheHeight = 400,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: Container(
        width: width,
        height: height,
        color: AppColors.surface,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          LucideIcons.imageOff,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}
