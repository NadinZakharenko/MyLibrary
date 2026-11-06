import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/data/cover_text_recognizer.dart';

class MlkitCoverTextRecognizer implements CoverTextRecognizer {
  const MlkitCoverTextRecognizer();

  @override
  Future<String?> recognizeFile(String absolutePath) async {
    if (!deviceCaptureSupported) {
      return null;
    }
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(absolutePath),
      );
      final text = recognized.text.trim();
      if (text.isEmpty) {
        return null;
      }
      return text;
    } finally {
      await recognizer.close();
    }
  }
}
