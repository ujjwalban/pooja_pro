import 'package:flutter/material.dart';
import '../firebase/firebase_image.dart';
import '../components/media_thumbnail.dart';

String url =
    "https://as2.ftcdn.net/v2/jpg/10/57/88/03/1000_F_1057880355_SkadoritQwzkQZ24imNZAKCtIitSUgMq.jpg";
Widget mediaPreview(mediaUrlController) {
  // If nothing is selected, show the default mandir icon.
  if (mediaUrlController.text.isEmpty) {
    return MediaThumbnail(
      url: url,
      height: 150,
      width: 150,
    );
  } else if (mediaUrlController.text.endsWith('.mp4')) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 150,
          width: 150,
          color: Colors.black,
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
      ],
    );
  } else {
    return MediaThumbnail(
      url: mediaUrlController.text,
      height: 150,
      width: 150,
    );
  }
}

class ImageUploader extends StatefulWidget {
  final TextEditingController mediaUrlController;
  const ImageUploader({super.key, required this.mediaUrlController});
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  bool isUploading = false;
  final FirebaseUploader uploader = FirebaseUploader();

  void chooseMedia(context, mediaUrlController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Media Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Image"),
                onTap: () async {
                  Navigator.pop(context); // Close media selection dialog
                  setState(() {
                    isUploading = true;
                  });
                  String? base64String =
                      await uploader.pickAndUploadMedia(isImage: true);
                  if (mounted) {
                    setState(() {
                      isUploading = false;
                      if (base64String != null && base64String.isNotEmpty) {
                        mediaUrlController.text = base64String;
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Video"),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    isUploading = true;
                  });
                  String? url =
                      await uploader.pickAndUploadMedia(isImage: false);
                  if (mounted) {
                    setState(() {
                      isUploading = false;
                      if (url != null && url.isNotEmpty) {
                        mediaUrlController.text = url;
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget imageUploader(context, mediaUrlController) {
    return GestureDetector(
      onTap: () {
        chooseMedia(context, mediaUrlController);
      },
      child: AbsorbPointer(
        child: TextField(
          controller: mediaUrlController,
          decoration: InputDecoration(
            labelText: "Media URL",
            suffixIcon: mediaUrlController.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.upload_file),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imageUploader(context, widget.mediaUrlController);
  }
}
