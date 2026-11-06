import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const shelfImageMaxSide = 2048;

class ShelfImageException implements Exception {
  const ShelfImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

Uint8List downscaleJpeg(Uint8List bytes, {int maxSide = shelfImageMaxSide}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const ShelfImageException('Не удалось прочитать фото.');
  }
  final longest = math.max(decoded.width, decoded.height);
  final scaled = longest <= maxSide
      ? decoded
      : decoded.width >= decoded.height
      ? img.copyResize(decoded, width: maxSide)
      : img.copyResize(decoded, height: maxSide);
  return Uint8List.fromList(img.encodeJpg(scaled, quality: 80));
}
