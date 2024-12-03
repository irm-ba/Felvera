import 'package:google_ml_kit/google_ml_kit.dart';

Future<bool> isPetImage(String imagePath) async {
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    // Hayvanlarla ilgili etiketler
    const validLabels = ['Cat', 'Dog', 'Animal', 'Pet'];
    for (var label in labels) {
      if (validLabels.contains(label.label)) {
        return true; // Resim hayvan içeriyor
      }
    }
    return false; // Resim uygun değil
  } catch (e) {
    print('Error processing image: $e');
    return false;
  }
}