import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

abstract class SpineScriptRecognizer {
  const SpineScriptRecognizer();

  Future<String> recognizeFile(String absolutePath, {String psm = '6'});
}

class TesseractSpineRecognizer implements SpineScriptRecognizer {
  const TesseractSpineRecognizer();

  @override
  Future<String> recognizeFile(String absolutePath, {String psm = '6'}) {
    return FlutterTesseractOcr.extractText(
      absolutePath,
      language: 'rus+eng',
      args: {
        'psm': psm,
        'preserve_interword_spaces': '1',
      },
    );
  }
}

class UnavailableSpineScriptRecognizer implements SpineScriptRecognizer {
  const UnavailableSpineScriptRecognizer();

  @override
  Future<String> recognizeFile(String absolutePath, {String psm = '6'}) async => '';
}
