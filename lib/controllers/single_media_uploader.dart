import 'package:flutter/material.dart';
import '../firebase/firebase_image.dart';
import '../components/media_thumbnail.dart';
import '../components/simple_video_player.dart';

class SingleMediaUploader extends StatefulWidget {
  final String initialMediaUrl;
  final Function(String) onMediaChanged;

  const SingleMediaUploader({
    Key? key,
    required this.initialMediaUrl,
    required this.onMediaChanged,
  }) : super(key: key);

  @override
  _SingleMediaUploaderState createState() => _SingleMediaUploaderState();
}

class _SingleMediaUploaderState extends State<SingleMediaUploader> {
  late String _mediaUrl;
  bool _isUploading = false;
  final FirebaseUploader uploader = FirebaseUploader();

  @override
  void initState() {
    super.initState();
    _mediaUrl = widget.initialMediaUrl;
  }

  Future<void> _pickMedia({required bool isImage}) async {
    setState(() {
      _isUploading = true;
    });

    try {
      debugPrint('Picking ${isImage ? 'image' : 'video'}');
      final url = await uploader.pickAndUploadMedia(isImage: isImage);

      if (url != null && url.isNotEmpty && mounted) {
        debugPrint('Media uploaded successfully: $url');
        setState(() {
          _mediaUrl = url;
        });
        widget.onMediaChanged(_mediaUrl);
      }
    } catch (e) {
      debugPrint('Error in _pickMedia: $e');

      // Show detailed error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error uploading ${isImage ? 'image' : 'video'}: ${e.toString().split('\n')[0]}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('${isImage ? 'Image' : 'Video'} Upload Error'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Media Preview
        GestureDetector(
          onTap: () => _showMediaPickerDialog(context),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              color: Colors.grey.shade100,
            ),
            child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : _mediaUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _mediaUrl.endsWith('.mp4')
                            ? SimpleVideoPlayer(
                                videoUrl: _mediaUrl,
                                autoPlay: false,
                                showControls: true,
                                fit: BoxFit.cover,
                              )
                            : MediaThumbnail(
                                url: _mediaUrl,
                                fit: BoxFit.cover,
                              ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add main photo',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),

        const SizedBox(height: 16),

        // Upload Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _pickMedia(isImage: true),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _pickMedia(isImage: false),
              icon: const Icon(Icons.videocam),
              label: const Text('Add Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMediaPickerDialog(BuildContext context) {
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
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(isImage: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text("Video"),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(isImage: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
