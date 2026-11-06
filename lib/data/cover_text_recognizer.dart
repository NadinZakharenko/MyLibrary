abstract class CoverTextRecognizer {
  const CoverTextRecognizer();

  Future<String?> recognizeFile(String absolutePath);
}

class UnavailableCoverTextRecognizer implements CoverTextRecognizer {
  const UnavailableCoverTextRecognizer();

  @override
  Future<String?> recognizeFile(String absolutePath) async => null;
}
