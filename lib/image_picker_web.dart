import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

Future<Uint8List?> pickImage() async {
  final completer = Completer<Uint8List?>(); // Asenkron işlemi beklemek için
  html.FileUploadInputElement uploadInput =
      html.FileUploadInputElement(); // Dosya seçici elemanı
  uploadInput.accept = 'image/*'; // Sadece resim dosyalarını kabul et
  uploadInput.click(); // Kullanıcıya dosya seçici penceresini aç

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files; // Seçilen dosyaları al
    if (files != null && files.isNotEmpty) {
      final reader = html.FileReader(); // Seçilen dosyanın içeriğini okur
      reader.readAsArrayBuffer(files[0]); // Dosyayı binary formatında oku
      reader.onLoadEnd.listen((event) {
        completer.complete(
            reader.result as Uint8List); // İşlem tamamlanınca byte array dön
      });
    } else {
      completer.complete(null); // Eğer dosya seçilmezse null döndür
    }
  });

  return completer.future;
}
