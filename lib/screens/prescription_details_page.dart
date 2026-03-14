import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrescriptionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PrescriptionDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final createdAt = (data['createdAt']).toDate();

    return Scaffold(
      appBar: AppBar(title: const Text("Medicine Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: "Verification Request",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Request Number: ${data['requestNumber']}"),
                  Text(
                    "Request Time: ${DateFormat('dd MMM yyyy HH:mm').format(createdAt)}",
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: "Status",
              child: Row(
                children: [
                  Text(
                    data['status'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: data['status'] == "Found Error"
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (data['status'] == "Found Error")
                    const Icon(Icons.error, color: Colors.red),
                ],
              ),
            ),

            if (data['errorMessage'] != null)
              _sectionCard(
                title: "Verification Details",
                child: Text(data['errorMessage']),
              ),

            _sectionCard(
              title: "Doctor & Hospital",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Doctor: ${data['doctorName'] ?? 'Not found'}"),
                  Text("Hospital: ${data['hospitalName'] ?? 'Not found'}"),
                ],
              ),
            ),

            _sectionCard(
              title: "Medicines",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (data['medicines'] as List<dynamic>? ?? [])
                    .map((m) => Text("• $m"))
                    .toList(),
              ),
            ),

            _sectionCard(
              title: "Extracted Text",
              child: Text(data['extractedText'] ?? ''),
            ),

            _imageBlock("Prescription Photo", data['prescriptionImageUrl']),
            _imageBlock("Medicine Photo", data['medicineImageUrl']),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _imageBlock(String title, String? url) {
    if (url == null || url.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(url, height: 180, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
