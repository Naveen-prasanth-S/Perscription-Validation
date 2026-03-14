import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/ocr_service.dart';
import '../services/text_preprocessing_service.dart';
import '../services/prescription_extractor.dart';
import '../services/prescription_backend_service.dart';
import '../models/prescription_data.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final ImagePicker _picker = ImagePicker();
  final OCRService ocrService = OCRService();
  final TextPreprocessingService preprocessingService = TextPreprocessingService();

  final List<XFile> prescriptionImages = [];
  final List<XFile> medicineImages = [];
  final TextEditingController _commentsController = TextEditingController();

  String extractedPrescriptionText = "";
  bool isExtractingText = false;
  bool isSubmitting = false;

  // ---------------- PICK PRESCRIPTION IMAGE ----------------
  Future<void> pickPrescriptionImage() async {
    if (prescriptionImages.length >= 4) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        prescriptionImages.add(image);
        isExtractingText = true;
      });

      final rawText = await ocrService.extractText(File(image.path));
      final cleanedText = preprocessingService.cleanText(rawText);

      // Optional: Correct common OCR misreads (i→1, o→0, l→1)
      final correctedText = cleanedText
          .replaceAll(RegExp(r'\bi\b'), '1')
          .replaceAll(RegExp(r'\bo\b'), '0')
          .replaceAll(RegExp(r'\bl\b'), '1');

      setState(() {
        extractedPrescriptionText += "\n$correctedText";
        isExtractingText = false;
      });

      debugPrint("CLEANED OCR TEXT:");
      debugPrint(correctedText);
    }
  }

  // ---------------- PICK MEDICINE IMAGE ----------------
  Future<void> pickMedicineImage() async {
    if (medicineImages.length >= 10) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => medicineImages.add(image));
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Request"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recommendations", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Please add clear and visible photos of Prescription and Medicine. "
                "This helps us verify and respond quickly.",
              ),
            ),
            const SizedBox(height: 20),

            // -------- PRESCRIPTION PHOTOS --------
            const Text("Prescription photos"),
            const Text("Note: Max 4 photos only", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: pickPrescriptionImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Upload Prescription"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: prescriptionImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(
                      File(prescriptionImages[index].path),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            if (isExtractingText)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 20),

            // -------- MEDICINE PHOTOS --------
            const Text("Medicine photos"),
            const Text("Note: Max 10 photos only", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: pickMedicineImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Upload Medicine"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: medicineImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(
                      File(medicineImages[index].path),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // -------- USER COMMENTS --------
            const Text("User Comments"),
            const SizedBox(height: 8),
            TextField(
              controller: _commentsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter your comments here",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // -------- SUBMIT BUTTON --------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitPrescription,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Submit"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- SUBMIT PRESCRIPTION ---------------------
  Future<void> _submitPrescription() async {
    if (extractedPrescriptionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a prescription image")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // STEP 1: Get signed-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be signed in to submit a prescription")),
        );
        setState(() => isSubmitting = false);
        return;
      }
      final userId = user.uid;

      // STEP 2: Extract data
      final extractor = PrescriptionExtractor();
      final data = extractor.extract(extractedPrescriptionText);

      // STEP 3: Validation placeholder
      const validationStatus = "Processing";
      final List<String> issues = [];

      // STEP 4: Store to Firestore
      final backend = PrescriptionBackendService();
      await backend.storePrescription(
        userId: userId,
        extractedText: extractedPrescriptionText,
        data: data,
        validationStatus: validationStatus,
        issues: issues,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Submitted Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}
