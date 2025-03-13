import 'package:flutter/material.dart';
import '../components/simple_carousel.dart';
import '../firebase/firebase_image.dart';
import '../components/media_thumbnail.dart';

class SimpleMediaUploader extends StatefulWidget {
  final List<String> mediaUrls;
  final Function(List<String>) onMediaChanged;

  const SimpleMediaUploader({
    Key? key,
    required this.mediaUrls,
    required this.onMediaChanged,
  }) : super(key: key);

  @override
  _SimpleMediaUploaderState createState() => _SimpleMediaUploaderState();
}

class _SimpleMediaUploaderState extends State<SimpleMediaUploader> {
  List<String> _mediaUrls = [];
  bool isUploading = false;
  final FirebaseUploader uploader = FirebaseUploader();

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
                  String? mediaUrl =
                      await uploader.pickAndUploadMedia(isImage: true);
                  setState(() {
                    isUploading = false;
                    if (mediaUrl != null && mediaUrl.isNotEmpty) {
                      _mediaUrls.add(mediaUrl);
                      widget.onMediaChanged(_mediaUrls);
                    }
                  });
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
                  String? mediaUrl =
                      await uploader.pickAndUploadMedia(isImage: false);
                  setState(() {
                    isUploading = false;
                    if (mediaUrl != null && mediaUrl.isNotEmpty) {
                      _mediaUrls.add(mediaUrl);
                      widget.onMediaChanged(_mediaUrls);
                    }
                  });
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
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 50,
              ),
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
            child: SimpleCarousel(
              items: _mediaUrls.asMap().entries.map((entry) {
                int index = entry.key;
                String mediaUrl = entry.value;
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
              }).toList(),
              autoPlay: false,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
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
