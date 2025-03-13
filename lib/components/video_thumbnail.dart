import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'simple_video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback? onTap;

  const VideoThumbnail({
    Key? key,
    required this.videoUrl,
    this.width = 110,
    this.height = 110,
    this.borderRadius = 12,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    _initializeController();
  }

  void _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      // Get a frame from the start of the video
      if (_controller.value.duration.inMilliseconds > 500) {
        await _controller.seekTo(const Duration(milliseconds: 500));
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      _animationController.stop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      _animationController.stop();
      debugPrint('Error initializing video thumbnail: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showVideoPlayer(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Video player
            Expanded(
              child: Center(
                child: SimpleVideoPlayer(
                  videoUrl: widget.videoUrl,
                  autoPlay: true,
                  showControls: true,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Video error widget
  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey.shade600,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            'Video Error',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Animated loading skeleton
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
                    stops: [
                      _animationController.value - 0.3,
                      _animationController.value,
                      _animationController.value + 0.3,
                    ].map((v) => v.clamp(0.0, 1.0)).toList(),
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.9),
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
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onTap ?? () => _showVideoPlayer(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video thumbnail
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          ),

          // Dark overlay for better visibility of play button
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Large centered play button
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
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

          // Video duration indicator
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
