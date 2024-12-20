import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerExample extends StatefulWidget {
  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  Uint8List? _imageBytes;

  Future<void> pickImage() async {
    // Kullanıcıdan bir dosya seçmesini isteyin
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Sadece görselleri seçmesine izin ver
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes; // Görselin verisini al
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görsel Yükleme'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Görseli göster
            if (_imageBytes != null)
              Image.memory(_imageBytes!)
            else
              Text('Henüz bir görsel yüklenmedi.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Görsel Yükle'),
            ),
          ],
        ),
      ),
    );
  }
}
