import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Function? onClose;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.onClose,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  double _volume = 1.0;
  bool _showControls = true;
  bool _isFullScreen = false;
  late AnimationController _loadingAnimationController;
  bool _isDragging = false;
  double _currentSliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown
      setState(() {});
    });

    // Add listener for play/pause state
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }

      // Update slider position
      if (!_isDragging && _controller.value.isInitialized) {
        setState(() {
          _currentSliderValue = _controller.value.position.inSeconds.toDouble();
        });
      }
    });

    // Animation controller for loading animation
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
      _controller.setVolume(value);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void _skipForward() {
    final newPosition =
        _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  void _skipBackward() {
    final newPosition =
        _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dark background with animated gradient
        AnimatedBuilder(
          animation: _loadingAnimationController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.grey.shade800.withOpacity(
                        0.5 + _loadingAnimationController.value * 0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            );
          },
        ),

        // Animated loading indicator
        AnimatedBuilder(
          animation: _loadingAnimationController,
          builder: (context, child) {
            final value = _loadingAnimationController.value;
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5 * value,
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  value: null,
                  strokeWidth: 3,
                ),
              ),
            );
          },
        ),

        const Positioned(
          bottom: 40,
          child: Text(
            'Loading video...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: const Text(
                'Video Player',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0,
            ),
      body: SafeArea(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                onTap: _toggleControls,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),

                    // Controls
                    if (_showControls)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Center play/pause button
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange
                                      .withOpacity(_isPlaying ? 0.8 : 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),

                            // Skip backward button (left)
                            Positioned(
                              left: 30,
                              child: GestureDetector(
                                onTap: _skipBackward,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Skip forward button (right)
                            Positioned(
                              right: 30,
                              child: GestureDetector(
                                onTap: _skipForward,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Bottom controls
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Progress slider
                                    ValueListenableBuilder(
                                      valueListenable: _controller,
                                      builder: (context, VideoPlayerValue value,
                                          child) {
                                        // Show empty container if video is not initialized
                                        if (!value.isInitialized) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          children: [
                                            // Progress slider
                                            SliderTheme(
                                              data: const SliderThemeData(
                                                trackHeight: 4,
                                                activeTrackColor:
                                                    Colors.deepOrange,
                                                inactiveTrackColor:
                                                    Colors.white24,
                                                thumbColor: Colors.white,
                                                thumbShape:
                                                    RoundSliderThumbShape(
                                                  enabledThumbRadius: 6,
                                                ),
                                                overlayColor:
                                                    Colors.transparent,
                                                overlayShape:
                                                    RoundSliderOverlayShape(
                                                  overlayRadius: 14,
                                                ),
                                              ),
                                              child: Slider(
                                                value: _currentSliderValue >
                                                        value.duration.inSeconds
                                                            .toDouble()
                                                    ? value.duration.inSeconds
                                                        .toDouble()
                                                    : _currentSliderValue,
                                                min: 0,
                                                max: value.duration.inSeconds
                                                    .toDouble(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _currentSliderValue =
                                                        newValue;
                                                    _isDragging = true;
                                                  });
                                                },
                                                onChangeStart: (value) {
                                                  setState(() {
                                                    _isDragging = true;
                                                  });
                                                },
                                                onChangeEnd: (newValue) {
                                                  setState(() {
                                                    _isDragging = false;
                                                    _controller.seekTo(Duration(
                                                        seconds:
                                                            newValue.toInt()));
                                                  });
                                                },
                                              ),
                                            ),

                                            // Time indicators
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatDuration(
                                                        value.position),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatDuration(
                                                        value.duration),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 8),

                                    // Control buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Volume button and slider
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                _volume > 0
                                                    ? Icons.volume_up
                                                    : Icons.volume_off,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _setVolume(
                                                    _volume > 0 ? 0.0 : 1.0);
                                              },
                                            ),
                                            SizedBox(
                                              width: 80,
                                              child: SliderTheme(
                                                data: const SliderThemeData(
                                                  trackHeight: 2,
                                                  activeTrackColor:
                                                      Colors.deepOrange,
                                                  inactiveTrackColor:
                                                      Colors.white24,
                                                  thumbColor: Colors.white,
                                                  thumbShape:
                                                      RoundSliderThumbShape(
                                                    enabledThumbRadius: 5,
                                                  ),
                                                  overlayColor:
                                                      Colors.transparent,
                                                ),
                                                child: Slider(
                                                  value: _volume,
                                                  min: 0.0,
                                                  max: 1.0,
                                                  onChanged: _setVolume,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Fullscreen toggle
                                        IconButton(
                                          icon: Icon(
                                            _isFullScreen
                                                ? Icons.fullscreen_exit
                                                : Icons.fullscreen,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onPressed: _toggleFullScreen,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return _buildLoadingIndicator();
            }
          },
        ),
      ),
    );
  }
}
