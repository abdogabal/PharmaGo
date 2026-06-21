import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:pharmago/Services/OcrService.dart';
import 'package:pharmago/Models/Medicines.dart';
import 'package:pharmago/core/SupabaseHandler.dart';
import 'package:pharmago/Providers/CartProvider.dart';

class ScanPrescriptionScreen extends StatefulWidget {
  static const String routeName = "scan_prescription";
  const ScanPrescriptionScreen({super.key});

  @override
  State<ScanPrescriptionScreen> createState() =>
      _ScanPrescriptionScreenState();
}

class _ScanPrescriptionScreenState extends State<ScanPrescriptionScreen> {
  File? _image;
  bool _loading = false;
  String _rawOcrText = "";
  List<_MedicineMatch> _matches = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 2048);
    if (file != null) {
      setState(() {
        _image = File(file.path);
        _matches = [];
        _loading = true;
      });
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    // Step 1: OCR - send whole image to TrOCR
    final rawText = await OcrService.recognizeText(_image!);
    _rawOcrText = rawText;

    // Step 2: Parse recognized text into possible medicine names
    final words = rawText
        .replaceAll(RegExp(r'[.,!?;:]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();

    // Step 3: Search Supabase for matching medicines
    final allMedicines =
        await SupabaseHandler.supabase.from('medicines').select('*');
    final medicineList =
        (allMedicines as List).map((m) => Medic.fromJson(m)).toList();

    // Step 4: Fuzzy match each OCR word against medicine names
    final Set<String> matchedNames = {};
    final List<_MedicineMatch> results = [];

    for (final word in words) {
      double bestScore = 0;
      Medic? bestMatch;
      String bestName = "";

      for (final med in medicineList) {
        if (med.name == null) continue;
        final score = word.toLowerCase().similarityTo(med.name!.toLowerCase());
        if (score > bestScore) {
          bestScore = score;
          bestMatch = med;
          bestName = med.name!;
        }
        // Also check active ingredient
        if (med.activeIngredient != null) {
          final ingScore = word
              .toLowerCase()
              .similarityTo(med.activeIngredient!.toLowerCase());
          if (ingScore > bestScore) {
            bestScore = ingScore;
            bestMatch = med;
            bestName = med.name!;
          }
        }
      }

      if (bestScore >= 0.4 && !matchedNames.contains(bestName)) {
        matchedNames.add(bestName);
        results.add(_MedicineMatch(
          recognized: word,
          medicine: bestMatch,
          confidence: bestScore,
        ));
      }
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    setState(() {
      _loading = false;
      _matches = results;
    });
  }

  void _addToCart(Medic? med) {
    if (med == null) return;
    Provider.of<CartProvider>(context, listen: false).addItem(med);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${med.name} added to cart"), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Prescription"),
        actions: [
          if (_matches.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                for (final m in _matches) {
                  _addToCart(m.medicine);
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Add All"),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_image != null)
            Container(
              height: 200,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Reading prescription and matching medicines..."),
                ],
              ),
            ),
          if (!_loading && _matches.isEmpty && _image != null)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text("No medicines recognized. Try a clearer photo."),
                  const SizedBox(height: 16),
                  Text("OCR raw: $_rawOcrText",
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          if (_matches.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];
                  final med = match.medicine;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade50,
                        child: Text("${(match.confidence * 100).toInt()}%",
                            style: TextStyle(
                                fontSize: 12,
                                color: match.confidence > 0.7
                                    ? Colors.green
                                    : Colors.orange)),
                      ),
                      title: Text(med?.name ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "OCR read: \"${match.recognized}\""
                          "${med?.price != null ? '  \$${med!.price!.toStringAsFixed(2)}' : ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: Colors.teal),
                        onPressed: () => _addToCart(med),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_image == null && !_loading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.document_scanner,
                        size: 80, color: Colors.teal.shade300),
                    const SizedBox(height: 16),
                    const Text("Take a photo of the prescription",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "camera",
            onPressed: () => _pickImage(ImageSource.camera),
            backgroundColor: Colors.teal,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "gallery",
            mini: true,
            onPressed: () => _pickImage(ImageSource.gallery),
            backgroundColor: Colors.teal.shade200,
            child: const Icon(Icons.photo_library, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MedicineMatch {
  final String recognized;
  final Medic? medicine;
  final double confidence;
  _MedicineMatch({
    required this.recognized,
    required this.medicine,
    required this.confidence,
  });
}
