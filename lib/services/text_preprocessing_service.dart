class TextPreprocessingService {
  String cleanText(String rawText) {
    String text = rawText.toLowerCase();

    // Remove extra spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Fix OCR spacing issues
    text = text.replaceAll(' mg', 'mg');
    text = text.replaceAll(' m g', 'mg');
    text = text.replaceAll(' ml', 'ml');
    text = text.replaceAll(' m l', 'ml');

    // Fix common OCR character issues
    text = text.replaceAll('0', 'o');
    text = text.replaceAll('1', 'i');

    // Remove unwanted special characters
    text = text.replaceAll(RegExp(r'[^\w\s\.]'), '');

    return text.trim();
  }
}
