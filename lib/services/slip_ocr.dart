import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class SlipOcr {
  /// Reads a slip on the phone. Tesseract uses the Thai and English models
  /// shipped with the app. ML Kit's Latin model is a second pass for digits
  /// and English words. The draft still opens in the entry form, and nothing
  /// is stored until Save.
  Future<String> recognize(String path) async {
    final parts = <String>[];
    final thai = await _tesseract(path);
    if (thai.isNotEmpty) parts.add(thai);
    final latin = await _latin(path);
    if (latin.isNotEmpty) parts.add(latin);
    if (parts.isEmpty) {
      throw StateError('Slip reading returned no text');
    }
    final text = parts.join('\n');
    debugPrint('BahtBuddy OCR: $text');
    return text;
  }

  Future<String> _tesseract(String path) async {
    try {
      final text = await TesseractOcr.extractText(
        path,
        config: const OCRConfig(
          language: 'tha+eng',
          engine: OCREngine.tesseract,
          options: {
            TesseractConfig.preserveInterwordSpaces: '1',
            TesseractConfig.pageSegMode: PageSegmentationMode.singleBlock,
          },
        ),
      );
      return text.trim();
    } catch (error, stack) {
      debugPrint('BahtBuddy Tesseract: $error\n$stack');
      return '';
    }
  }

  Future<String> _latin(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return result.text.trim();
    } catch (error, stack) {
      debugPrint('BahtBuddy ML Kit: $error\n$stack');
      return '';
    } finally {
      await recognizer.close();
    }
  }
}
