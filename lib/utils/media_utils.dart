import 'package:flutter/material.dart';
import '../components/media_thumbnail.dart';

/// Utility class for handling media files (images and videos)
class MediaUtils {
  /// Checks if a URL points to a video file
  static bool isVideoUrl(String url) {
    final lowercaseUrl = url.toLowerCase();

    // Check for common video file extensions
    if (lowercaseUrl.endsWith('.mp4') ||
        lowercaseUrl.endsWith('.mov') ||
        lowercaseUrl.endsWith('.avi') ||
        lowercaseUrl.endsWith('.webm') ||
        lowercaseUrl.endsWith('.mkv') ||
        lowercaseUrl.endsWith('.m4v')) {
      return true;
    }

    // Check for video keywords in URL
    if (lowercaseUrl.contains('video')) {
      return true;
    }

    // Check for Firebase Storage video path patterns
    if (lowercaseUrl.contains('firebasestorage') &&
        (lowercaseUrl.contains('/videos%2F') ||
            lowercaseUrl.contains('/videos/'))) {
      return true;
    }

    return false;
  }

  /// Creates an appropriate thumbnail widget for a media URL
  static Widget getMediaThumbnail({
    required String url,
    double width = 50,
    double height = 50,
    double borderRadius = 8,
    Function()? onTap,
  }) {
    return MediaThumbnail(
      url: url,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
    );
  }
}
