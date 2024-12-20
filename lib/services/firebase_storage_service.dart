import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final FirebaseStorage _storage = FirebaseStorage.instance;
final picker = ImagePicker();

Future<String?> uploadImage() async {
  // Resim seçimi
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return null;

  // Yükleme işlemi
  File imageFile = File(pickedFile.path);
  String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Dosya adı

  try {
    // Firebase Storage'a yükleyin
    TaskSnapshot snapshot = await _storage.ref('images/$fileName').putFile(imageFile);

    // Yüklenen dosyanın URL'sini alın
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;  // URL'yi döndürüyoruz
  } catch (e) {
    print("Resim yükleme hatası: $e");
    return null;
  }
}
