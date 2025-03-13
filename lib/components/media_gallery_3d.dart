import 'package:flutter/material.dart';
import 'video_thumbnail.dart';
import 'custom_carousel.dart';
import 'media_thumbnail.dart';

class MediaGallery3D extends StatefulWidget {
  final List<String> mediaUrls;
  final bool isInteractive;
  final Function(int)? onMediaTap;

  const MediaGallery3D({
    Key? key,
    required this.mediaUrls,
    this.isInteractive = true,
    this.onMediaTap,
  }) : super(key: key);

  @override
  _MediaGallery3DState createState() => _MediaGallery3DState();
}

class _MediaGallery3DState extends State<MediaGallery3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final CustomCarouselController _carouselController =
      CustomCarouselController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build 3D gallery
  Widget _build3DGallery() {
    if (widget.mediaUrls.isEmpty) {
      return const Center(child: Text("No media available"));
    }

    List<Widget> mediaItems = widget.mediaUrls.map((url) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _Transform3DContainer(
            angle: _animation.value * 0.05,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () {
                    if (widget.onMediaTap != null) {
                      widget.onMediaTap!(_currentIndex);
                    }
                  },
                  child: url.endsWith('.mp4')
                      ? _buildVideoPlayer(url)
                      : _buildImageWithEffect(url),
                ),
              ),
            ),
          );
        },
      );
    }).toList();

    return CustomCarousel(
      items: mediaItems,
      height: 300,
      autoPlay: false,
      enlargeCenterPage: true,
      viewportFraction: 0.8,
      controller: _carouselController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget _buildVideoPlayer(String url) {
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: VideoThumbnail(
          videoUrl: url,
          width: double.infinity,
          height: double.infinity,
          borderRadius: 15,
        ),
      ),
    );
  }

  Widget _buildImageWithEffect(String url) {
    // For videos, use VideoThumbnail with play button
    if (url.endsWith('.mp4')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          VideoThumbnail(
            videoUrl: url,
            width: double.infinity,
            height: double.infinity,
            borderRadius: 15,
          ),
          if (widget.isInteractive)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      // For images, use MediaThumbnail
      return Stack(
        fit: StackFit.expand,
        children: [
          MediaThumbnail(
            url: url,
            fit: BoxFit.cover,
          ),
          if (widget.isInteractive && widget.mediaUrls.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.mediaUrls.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _build3DGallery();
  }
}

// Media Grid
class MediaGrid3D extends StatelessWidget {
  final List<String> mediaUrls;
  final Function(int) onTap;

  const MediaGrid3D({
    Key? key,
    required this.mediaUrls,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: mediaUrls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return MediaTile3D(
          mediaUrl: mediaUrls[index],
          onTap: () => onTap(index),
        );
      },
    );
  }
}

class MediaTile3D extends StatefulWidget {
  final String mediaUrl;
  final VoidCallback onTap;

  const MediaTile3D({
    Key? key,
    required this.mediaUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  _MediaTile3DState createState() => _MediaTile3DState();
}

class _MediaTile3DState extends State<MediaTile3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovering = true;
        _controller.forward();
      }),
      onExit: (_) => setState(() {
        _isHovering = false;
        _controller.reverse();
      }),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_controller.value * 0.05)
              ..rotateY(_controller.value * 0.05)
              ..scale(1 + _controller.value * 0.1),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_controller.value * 0.3),
                      blurRadius: 5 + _controller.value * 15,
                      offset: Offset(0, 3 + _controller.value * 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.mediaUrl.endsWith('.mp4')
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: VideoThumbnail(
                                videoUrl: widget.mediaUrl,
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 10,
                              ),
                            ),
                          ],
                        )
                      : MediaThumbnail(
                          url: widget.mediaUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// A container for 3D transform effects
class _Transform3DContainer extends StatelessWidget {
  final Widget child;
  final double angle;

  const _Transform3DContainer({
    Key? key,
    required this.child,
    this.angle = 0.05,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle),
      child: child,
    );
  }
}
