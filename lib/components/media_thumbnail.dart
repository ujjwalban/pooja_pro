import 'package:flutter/material.dart';
import '../utils/media_utils.dart';
import 'video_thumbnail.dart';
import 'simple_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a media thumbnail (image or video)
/// Can be used as a drop-in replacement for Image.network
class MediaThumbnail extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showPlayIcon;
  final Function()? onTap;

  const MediaThumbnail({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showPlayIcon = true,
    this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    final isVideo = MediaUtils.isVideoUrl(url);

    if (isVideo) {
      _showVideoPlayer(context);
    } else if (url.isNotEmpty) {
      _showImageViewer(context);
    }
  }

  void _showVideoPlayer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: SimpleVideoPlayer(
                  videoUrl: url,
                  autoPlay: true,
                  showControls: true,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageViewer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey),
        ),
      );
    }

    // For video URLs, show a video thumbnail
    if (MediaUtils.isVideoUrl(url)) {
      return GestureDetector(
        onTap: () => _handleTap(context),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: VideoThumbnail(
            videoUrl: url,
            width: width ?? 110,
            height: height ?? 110,
            borderRadius: borderRadius != null ? borderRadius!.topLeft.x : 12,
          ),
        ),
      );
    }

    // For image URLs, use CachedNetworkImage for caching
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
