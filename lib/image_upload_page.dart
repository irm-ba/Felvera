import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb kullanabilmek için
import 'package:firebase_storage/firebase_storage.dart'; // Firebase ile çalışmak için gerekli
import 'package:image_picker/image_picker.dart'; // Resim seçmek için kullanılır

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  String? imageUrl;  // Firebase'den alınan URL'yi burada saklayacağız
  File? imageFile;   // Mobil için cihazdaki dosyayı saklamak

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resim Yükleme")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Resmi uygun şekilde göster
            imageUrl == null && imageFile == null
                ? Text("Henüz resim yüklenmedi.")
                : kIsWeb
                ? Image.network(imageUrl!)  // Web için Image.network kullan
                : Image.file(imageFile!),   // Mobil için Image.file kullan
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? url = await uploadImage();
                if (url != null) {
                  setState(() {
                    imageUrl = url; // Firebase'den gelen URL'yi kullan
                  });
                }
              },
              child: Text("Resim Yükle"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImage() async {
    // Firebase Storage'a yükleme işlemi
    // Cihazdan resim seçme işlemi
    if (kIsWeb) {
      // Web için Image Picker kullanamayız, genellikle kullanıcı URL üzerinden seçer
      // Bunun yerine Firebase Storage'dan bir URL alabilirsiniz
      return await uploadImageToFirebase();  // Firebase Storage'dan URL almak
    } else {
      // Mobil için image picker kullanarak resim seçimi yapılır
      // Resim seçme işlemi
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      File image = File(pickedFile.path);
      imageFile = image;

      // Firebase Storage'a yükleme
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('images/$fileName')
            .putFile(image);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print("Resim yükleme hatası: $e");
        return null;
      }
    }
  }

  Future<String?> uploadImageToFirebase() async {
    // Web için Firebase Storage'a yükleme işlemi
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // Web için Firebase Storage'a yükleme
      final imagePath = 'path/to/your/image';  // Web'de dosya yolu yerine URL kullanabilirsiniz
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('images/$fileName')
          .putFile(File(imagePath));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Webde resim yüklenirken hata: $e");
      return null;
    }
  }
}
