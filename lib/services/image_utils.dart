import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUtils {
  // Resim seçici (web ve mobil uyumlu)
  static Future<Uint8List?> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

  // Firebase'e resim yükleme
  static Future<String?> uploadImage(Uint8List imageBytes, String path) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final Reference storageRef =
      FirebaseStorage.instance.ref().child('$path/$fileName');

      await storageRef.putData(imageBytes);
      return await storageRef.getDownloadURL();
    } catch (e) {
      // Hata durumunu loglayabilirsiniz
      print('Resim yükleme hatası: $e');
      return null;
    }
  }
}
