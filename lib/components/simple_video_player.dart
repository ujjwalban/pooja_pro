import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/video_cache_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SimpleVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  final VideoCacheManager _cacheManager = VideoCacheManager();
  bool _isLoadingFromCache = false;
  bool _isPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      debugPrint('Initializing video player with URL: ${widget.videoUrl}');

      // Check if the URL is valid
      if (widget.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      setState(() {
        _isLoadingFromCache = true;
      });

      // On web, we can't use caching
      if (kIsWeb) {
        final videoUri = Uri.parse(widget.videoUrl);
        _controller = VideoPlayerController.networkUrl(videoUri);
      } else {
        // Try to get the video from cache first
        final cachedPath =
            await _cacheManager.getCachedVideoPath(widget.videoUrl);

        if (cachedPath != null) {
          // Video is in cache, initialize with file
          _controller = VideoPlayerController.file(File(cachedPath));
          debugPrint('Playing video from cache: $cachedPath');
        } else {
          // Video is not in cache, initialize with network URL
          final videoUri = Uri.parse(widget.videoUrl);
          _controller = VideoPlayerController.networkUrl(videoUri);

          // Cache the video after initializing
          _cacheManager.cacheVideo(widget.videoUrl).then((path) {
            debugPrint('Video cached for future use: $path');
          });
        }
      }

      setState(() {
        _isLoadingFromCache = false;
      });

      // Set up listener before initialization
      _controller.addListener(() {
        // Check if state is mounted before calling setState
        if (mounted) {
          final isPlaying = _controller.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() => _isPlaying = isPlaying);
          }

          // Check for video errors
          if (_controller.value.hasError) {
            debugPrint(
                'Video player error: ${_controller.value.errorDescription}');
          }
        }
      });

      // Initialize the controller with timeout
      await _controller.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Video initialization timed out');
          throw Exception('Video initialization timed out');
        },
      );

      if (widget.autoPlay && mounted) {
        await _controller.play();
      }

      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlayerVisible = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      // If we can't initialize, still mark as initialized but show error UI
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoadingFromCache = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(SimpleVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If video URL changed, reinitialize
    if (widget.videoUrl != oldWidget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFromCache || !_isInitialized) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Loading gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Loading indicator
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isLoadingFromCache
                        ? 'Loading from cache...'
                        : 'Loading video...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Play button overlay
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.value.hasError) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
              const SizedBox(height: 8),
              const Text('Error loading video',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        if (_showControls) {
          _hideControlsAfterDelay();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          AnimatedOpacity(
            opacity: _isPlayerVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: FittedBox(
                fit: widget.fit,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),

          // Play/pause button overlay
          if (widget.showControls && _showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),
            ),

          // Bottom progress indicator
          if (widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 30,
                  color: Colors.black38,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.deepOrange,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black38,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
