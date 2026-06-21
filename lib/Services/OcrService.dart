import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OcrService {
  static const String _baseUrl =
      "https://eyadsakr11-trocr-prescription-reader.hf.space";

  static Future<String> recognizeText(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse("$_baseUrl/ocr"),
        headers: {"Content-Type": "image/jpeg"},
        body: bytes,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["text"] ?? "";
      }
      return "Error: ${response.statusCode} - ${response.body}";
    } catch (e) {
      return "Error: $e";
    }
  }
}
