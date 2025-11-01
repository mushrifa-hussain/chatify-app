import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File?> getImageFromLibrary() async {
    return ImagePicker().pickImage(source: ImageSource.gallery).then((
      pickedFile, //contains path, name, etc.,
    ) {
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    });
  }
}
