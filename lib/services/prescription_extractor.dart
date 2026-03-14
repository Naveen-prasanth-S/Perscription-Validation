// lib/services/prescription_extractor.dart

import '../models/prescription_data.dart';

class PrescriptionExtractor {
  PrescriptionData extract(String text) {
    final normalized = _normalize(text);

    final doctorName = _extractDoctorName(normalized);
    final hospitalName = _extractHospitalName(normalized);
    final medicines = _extractMedicineDetails(normalized);

    return PrescriptionData(
      doctorName: doctorName,
      hospitalName: hospitalName,
      medicines: medicines.map((m) => m['name']!).toList(),
      dosages: medicines.map((m) => m['dosage']!).toList(),
      frequencies: medicines.map((m) => m['frequency']!).toList(),
    );
  }

  // ---------------- NORMALIZATION ----------------
  String _normalize(String text) {
    return text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase()
        .trim();
  }

  // ---------------- DOCTOR NAME ----------------
  String? _extractDoctorName(String text) {
    final regExp = RegExp(
      r'dr\.?\s+[a-z]+\s+[a-z]+',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match != null ? _capitalize(match.group(0)!) : null;
  }

  // ---------------- HOSPITAL NAME ----------------
  String? _extractHospitalName(String text) {
    final regExp = RegExp(
      r'([a-z\s]+medical\s(center|centre|clinic|hospital))',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match != null ? _capitalize(match.group(0)!) : null;
  }

  // ---------------- MEDICINE DETAILS ----------------
  List<Map<String, String>> _extractMedicineDetails(String text) {
    final List<Map<String, String>> medicines = [];

    // Example matches:
    // betaloc 100 mg 1 tab bid
    // cimetidine 50 mg 2 tabs tid
    final regExp = RegExp(
      r'([a-z]+)\s*(\d+\s*mg|\d+\s*ml)\s*[-–]?\s*(\d+\s*(tab|tabs|tablet|tablets))?\s*(bid|tid|qid|qd|prn)?',
      caseSensitive: false,
    );

    for (final match in regExp.allMatches(text)) {
      medicines.add({
        'name': _capitalize(match.group(1)!),
        'dosage': match.group(2) ?? '',
        'frequency': (match.group(5) ?? '').toUpperCase(),
      });
    }

    return medicines;
  }

  // ---------------- UTILS ----------------
  String _capitalize(String value) {
    return value
        .split(' ')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1)
            : w)
        .join(' ');
  }
}
