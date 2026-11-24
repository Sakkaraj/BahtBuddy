import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SlipOcr {
  /// On-device Google ML Kit. The bundled model reads Latin letters and
  /// digits, which covers amounts, dates, references, and English names on
  /// Thai bank slips. ML Kit has no Thai-script model.
  Future<String> recognize(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      final text = result.text.trim();
      debugPrint('BahtBuddy OCR (${result.blocks.length} blocks): $text');
      if (text.isEmpty) {
        throw StateError('ML Kit returned no text');
      }
      return text;
    } finally {
      await recognizer.close();
    }
  }
}
