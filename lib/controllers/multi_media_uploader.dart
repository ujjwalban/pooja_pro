import 'package:flutter/material.dart';
import '../carousel_controller_patch.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../firebase/firebase_image.dart';
import '../components/media_thumbnail.dart';
import '../components/simple_video_player.dart';
import '../components/custom_carousel.dart';

class MediaFile {
  final String url;
  final bool isVideo;
  final String? thumbnailUrl;

  MediaFile({required this.url, required this.isVideo, this.thumbnailUrl});
}

class MultiMediaUploader extends StatefulWidget {
  final List<String> mediaUrls;
  final Function(List<String>) onMediaChanged;

  const MultiMediaUploader({
    Key? key,
    required this.mediaUrls,
    required this.onMediaChanged,
  }) : super(key: key);

  @override
  _MultiMediaUploaderState createState() => _MultiMediaUploaderState();
}

class _MultiMediaUploaderState extends State<MultiMediaUploader> {
  List<String> _mediaUrls = [];
  bool isUploading = false;
  final FirebaseUploader uploader = FirebaseUploader();
  final CustomCarouselController _carouselController =
      CustomCarouselController();

  @override
  void initState() {
    super.initState();
    _mediaUrls = List.from(widget.mediaUrls);
  }

  void _addMedia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Media Type"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text("Image"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    isUploading = true;
                  });
                  try {
                    String? mediaUrl =
                        await uploader.pickAndUploadMedia(isImage: true);
                    if (mounted) {
                      setState(() {
                        isUploading = false;
                        if (mediaUrl != null && mediaUrl.isNotEmpty) {
                          _mediaUrls.add(mediaUrl);
                          widget.onMediaChanged(_mediaUrls);
                        }
                      });
                    }
                  } catch (error) {
                    if (mounted) {
                      setState(() {
                        isUploading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error uploading image: $error')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text("Video"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    isUploading = true;
                  });
                  try {
                    String? mediaUrl =
                        await uploader.pickAndUploadMedia(isImage: false);
                    if (mounted) {
                      setState(() {
                        isUploading = false;
                        if (mediaUrl != null && mediaUrl.isNotEmpty) {
                          _mediaUrls.add(mediaUrl);
                          widget.onMediaChanged(_mediaUrls);
                        }
                      });
                    }
                  } catch (error) {
                    if (mounted) {
                      setState(() {
                        isUploading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error uploading video: $error'),
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Details',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Upload Error Details'),
                                  content: Text('$error'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
      widget.onMediaChanged(_mediaUrls);
    });
  }

  Widget _buildMediaPreview(String mediaUrl) {
    if (mediaUrl.isEmpty) {
      return const SizedBox.shrink();
    } else if (mediaUrl.endsWith('.mp4')) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: SimpleVideoPlayer(
              videoUrl: mediaUrl,
              autoPlay: false,
              showControls: false,
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: Center(
              child: Icon(Icons.play_arrow, size: 50, color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      return MediaThumbnail(
        url: mediaUrl,
        height: 150,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Media Gallery",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (_mediaUrls.isNotEmpty)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            child: CustomCarousel(
              controller: _carouselController,
              items: _mediaUrls.asMap().entries.map((entry) {
                int index = entry.key;
                String mediaUrl = entry.value;
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildMediaPreview(mediaUrl),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
              height: 200,
              autoPlay: false,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isUploading ? null : () => _addMedia(context),
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(isUploading ? "Uploading..." : "Add Media"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            if (_mediaUrls.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text("${_mediaUrls.length} files"),
            ],
          ],
        ),
      ],
    );
  }
}

// Widget to display a media gallery with 3D effects
class MediaGallery3D extends StatefulWidget {
  final List<String> mediaUrls;
  final bool isInteractive;
  final bool showPaginationDots;

  const MediaGallery3D({
    Key? key,
    required this.mediaUrls,
    this.isInteractive = true,
    this.showPaginationDots = true,
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

  // Build 3D cube-style transition for media
  Widget _build3DGallery() {
    if (widget.mediaUrls.isEmpty) {
      return const Center(child: Text("No media available"));
    }

    return CustomCarousel(
      controller: _carouselController,
      items: widget.mediaUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_animation.value * 0.05),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                      child: url.endsWith('.mp4')
                          ? SimpleVideoPlayer(
                              videoUrl: url,
                              autoPlay: false,
                              showControls: true,
                            )
                          : _buildImageWithEffect(url),
                    ),
                  ),
                );
              },
            );
          },
        );
      }).toList(),
      height: 300,
      autoPlay: widget.mediaUrls.length > 1,
      autoPlayInterval: const Duration(seconds: 5),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      enlargeCenterPage: true,
      viewportFraction: 0.8,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Widget _buildImageWithEffect(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MediaThumbnail(
          url: url,
          fit: BoxFit.cover,
        ),
        if (widget.isInteractive &&
            widget.showPaginationDots &&
            widget.mediaUrls.length > 1)
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

  @override
  Widget build(BuildContext context) {
    return _build3DGallery();
  }
}

// Media Grid with 3D hover effects
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
    return MasonryGridView.count(
      crossAxisCount: 4,
      itemCount: mediaUrls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return MediaTile3D(
          mediaUrl: mediaUrls[index],
          onTap: () => onTap(index),
        );
      },
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
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
                              child: SimpleVideoPlayer(
                                videoUrl: widget.mediaUrl,
                                autoPlay: false,
                                showControls: false,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              color: Colors.black
                                  .withOpacity(_isHovering ? 0.3 : 0.0),
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white
                                    .withOpacity(_isHovering ? 0.9 : 0.6),
                                size: 40,
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
