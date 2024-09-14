import 'dart:io'; // Mobil için dosya işlemleri
import 'package:image_picker/image_picker.dart'; // ImagePicker kütüphanesi

Future<File?> pickImage() async {
  final ImagePicker _picker = ImagePicker(); // Resim seçici nesnesi
  final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery); // Galeriden resim seç
  return pickedFile != null
      ? File(pickedFile.path)
      : null; // Seçilen dosyayı geri dön
}
