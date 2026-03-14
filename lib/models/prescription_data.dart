// lib/models/prescription_data.dart

class PrescriptionData {
  final String? doctorName;
  final String? hospitalName;
  final List<String> medicines;
  final List<String> dosages;
  final List<String> frequencies;

  PrescriptionData({
    this.doctorName,
    this.hospitalName,
    required this.medicines,
    required this.dosages,
    required this.frequencies,
  });
}
