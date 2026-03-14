import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription_data.dart';

class PrescriptionBackendService {
  final CollectionReference prescriptions =
      FirebaseFirestore.instance.collection('prescriptions');

  /// STORE PRESCRIPTION DATA
  Future<void> storePrescription({
    required String userId,
    required String extractedText,
    required PrescriptionData data,
    required String validationStatus,
    required List<String> issues,
  }) async {
    await prescriptions.add({
      'userId': userId,
      'extractedText': extractedText,
      'doctorName': data.doctorName ?? '',
      'hospitalName': data.hospitalName ?? '',
      'medicines': data.medicines,
      'dosages': data.dosages,
      'frequencies': data.frequencies,
      'validationStatus': validationStatus,
      'issues': issues,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// RETRIEVE PRESCRIPTIONS FOR A USER
  Stream<QuerySnapshot> getUserPrescriptions(String userId) {
    return prescriptions
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
