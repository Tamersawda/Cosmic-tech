import 'package:frontend/modules/admin/models/patient_model.dart';
import 'package:flutter/material.dart';

class PatientDetailsPanel extends StatelessWidget {
  final Patient patient;
  final VoidCallback onClose;

  const PatientDetailsPanel({
    super.key,
    required this.patient,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xffe5e7eb))),
        color: Colors.white,
      ),

      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Patient Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              CircleAvatar(radius: 28, child: Text(patient.name[0])),

              const SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(patient.id, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          info("Phone", patient.phone),
          info("Email", patient.email),
          info("Last Appointment", patient.lastAppointment),
          info("Total Appointments", patient.totalAppointments.toString()),
        ],
      ),
    );
  }

  Widget info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
