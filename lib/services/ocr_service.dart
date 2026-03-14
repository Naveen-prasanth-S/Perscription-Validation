import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'text_preprocessing_service.dart';

class OCRService {
  final TextPreprocessingService _preprocessingService = TextPreprocessingService();

  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    String cleanText = "";

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String ocrText = recognizedText.text;

      // Preprocess text
      cleanText = _preprocessingService.cleanText(ocrText);

      // ✅ Use print instead of debugPrint for full visibility in console
      if (kDebugMode) {
        print("\n===== EXTRACTED PRESCRIPTION TEXT =====");
      }
      if (kDebugMode) {
        print(cleanText);
      }
      if (kDebugMode) {
        print("=======================================\n");
      }

      return cleanText;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error in OCR: $e");
      }
      if (kDebugMode) {
        print(stackTrace);
      }
      return "";
    } finally {
      await textRecognizer.close();
    }
  }
}
