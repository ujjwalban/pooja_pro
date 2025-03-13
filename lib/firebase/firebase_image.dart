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
        // Set a maximum duration for videos
        pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 5),
        );
      }

      if (pickedFile == null) return null; // User canceled picking a file

      // Check file size - limit to 50MB for both images and videos
      final fileSize = await pickedFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        debugPrint('File size too large: ${fileSize / (1024 * 1024)}MB');
        throw Exception('File size should be less than 50MB');
      }

      // Generate a unique file name with timestamp
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}";

      // Create appropriate storage path
      final storagePath = isImage ? "images/$fileName" : "videos/$fileName";
      debugPrint('Uploading to: $storagePath');

      Reference ref = FirebaseStorage.instance.ref().child(storagePath);

      UploadTask uploadTask;
      if (kIsWeb) {
        // Read as bytes for web upload
        debugPrint('Uploading on web platform');
        final data = await pickedFile.readAsBytes();
        uploadTask = ref.putData(data);
      } else {
        // Upload the selected file directly
        debugPrint('Uploading on native platform');
        File file = File(pickedFile.path);
        uploadTask = ref.putFile(file);
      }

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;
      debugPrint('Upload complete! State: ${snapshot.state}');

      // Return the download URL of the uploaded file
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error in pickAndUploadMedia: $e');
      rethrow; // Rethrow to handle in the UI layer
    }
  }
}
