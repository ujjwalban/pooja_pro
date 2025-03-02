import 'dart:io';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUploader {
  final ImagePicker _picker = ImagePicker();

  /// Picks and uploads an image or video based on [isImage] flag.
  /// Returns the download URL upon success.
  Future<String?> pickAndUploadMedia({required bool isImage}) async {
    try {
      XFile? pickedFile;
      if (isImage) {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile == null) return null; // User canceled picking a file

      // Generate a unique file name with timestamp
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}.${isImage ? 'jpg' : 'mp4'}";
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(isImage ? "images/$fileName" : "videos/$fileName");

      UploadTask uploadTask;
      if (kIsWeb) {
        // Read as bytes for web upload
        final data = await pickedFile.readAsBytes();
        uploadTask = ref.putData(data);
      } else {
        // Upload the selected file directly
        File file = File(pickedFile.path);
        uploadTask = ref.putFile(file);
      }

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Return the download URL of the uploaded file
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
