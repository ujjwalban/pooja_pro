import 'dart:async';
import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final bool enlargeCenterPage;
  final double viewportFraction;
  final Function(int)? onPageChanged;
  final int initialPage;
  final CustomCarouselController? controller;

  const CustomCarousel({
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
    this.controller,
  }) : super(key: key);

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
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

    if (widget.controller != null) {
      widget.controller!._setPageController(_pageController);
    }

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

// Controller for CustomCarousel
class CustomCarouselController {
  PageController? _pageController;

  void _setPageController(PageController controller) {
    _pageController = controller;
  }

  void nextPage({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.nextPage(
        duration: duration,
        curve: curve,
      );
    }
  }

  void previousPage({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.previousPage(
        duration: duration,
        curve: curve,
      );
    }
  }

  void animateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.animateToPage(
        page,
        duration: duration,
        curve: curve,
      );
    }
  }
}
