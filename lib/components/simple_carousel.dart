import 'dart:async';
import 'package:flutter/material.dart';

/// A simple carousel widget that doesn't depend on carousel_slider package
class SimpleCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final bool enlargeCenterPage;
  final double viewportFraction;
  final Function(int)? onPageChanged;
  final int initialPage;

  const SimpleCarousel({
    Key? key,
    required this.items,
    this.height = 200.0,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.enlargeCenterPage = false,
    this.viewportFraction = 0.8,
    this.onPageChanged,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<SimpleCarousel> createState() => _SimpleCarouselState();
}

class _SimpleCarouselState extends State<SimpleCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage == widget.items.length - 1) {
          _pageController.animateToPage(
            0,
            duration: widget.autoPlayAnimationDuration,
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.nextPage(
            duration: widget.autoPlayAnimationDuration,
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                widget.onPageChanged?.call(index);
              },
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: widget.enlargeCenterPage && index == _currentPage
                        ? 0.0
                        : 8.0,
                  ),
                  child: widget.items[index],
                );
              },
            ),
          ),
          if (widget.items.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.deepOrange
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// A class to control the carousel from outside
class SimpleCarouselController {
  final PageController _pageController = PageController();

  void nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void animateToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  PageController get pageController => _pageController;
}

// A container for 3D transform effects
class TransformContainer extends StatelessWidget {
  final Widget child;
  final double angle;

  const TransformContainer({
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
