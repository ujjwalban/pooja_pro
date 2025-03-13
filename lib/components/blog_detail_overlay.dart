import 'package:flutter/material.dart';
import 'package:pooja_pro/models/blog.dart';
import 'media_gallery_3d.dart';

class BlogDetailOverlay extends StatefulWidget {
  final Blog blog;
  final Function onClose;

  const BlogDetailOverlay({
    Key? key,
    required this.blog,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BlogDetailOverlay> createState() => _BlogDetailOverlayState();
}

class _BlogDetailOverlayState extends State<BlogDetailOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Semi-transparent backdrop
              GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onClose();
                  });
                },
                child: Container(
                  color:
                      Colors.black.withOpacity(_opacityAnimation.value * 0.7),
                ),
              ),

              // Content card with 3D effect
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(0),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Media Gallery
                              if (widget.blog.mediaUrls.isNotEmpty)
                                SizedBox(
                                  height: 300,
                                  child: MediaGallery3D(
                                    mediaUrls: widget.blog.mediaUrls,
                                    isInteractive: true,
                                  ),
                                ),

                              // Blog Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.blog.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _controller.reverse().then((_) {
                                              widget.onClose();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 5),
                                        Text(
                                          widget.blog.dateTime,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 15),
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            widget.blog.location,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.blog.description,
                                      style: const TextStyle(
                                          fontSize: 16, height: 1.5),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
