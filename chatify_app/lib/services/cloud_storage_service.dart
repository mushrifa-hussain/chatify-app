import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();
  late FirebaseStorage _storage;
  late Reference _baseRef;

  final String _profileImages = "profile_images";
  final String messages = "messages";
  final String images = "images";

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<TaskSnapshot> uploadUserImage(String uid, File image) async {
    try {
      UploadTask uploadTask = _baseRef
          .child(_profileImages)
          .child(uid)
          .putFile(image);
      return await uploadTask;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<TaskSnapshot> uploadMediaImage(String conversationID, File file) {
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    var fileName = path.basename(file.path);
    fileName = timeStamp.toString();

    try {
      return _baseRef
          .child(messages)
          .child(conversationID)
          .child(images)
          .child(fileName)
          .putFile(file);
    } catch (e) {
      throw Exception("Error uploading media image: $e");
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception("Error deleting image: $e");
    }
  }
}
