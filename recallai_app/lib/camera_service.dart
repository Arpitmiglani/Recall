import 'package:image_picker/image_picker.dart';

class CameraService {

  final ImagePicker _picker = ImagePicker();

  Future<String?> takePicture() async {

    try {

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image == null) {
        return null;
      }

      return image.path;

    } catch (e) {

      print("Camera error: $e");
      return null;

    }
  }
}