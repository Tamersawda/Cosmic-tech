import 'package:frontend/modules/admin/presentation/models/patient_model.dart';
import 'package:flutter/material.dart';

class PatientDetailsPage extends StatelessWidget {
  final Patient patient;
  final VoidCallback onBack;

  const PatientDetailsPage({
    super.key,
    required this.patient,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),

      child: Card(
        elevation: 2,

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Patient Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  CircleAvatar(radius: 30, child: Text(patient.name[0])),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        patient.id,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              infoTile("Phone", patient.phone),
              infoTile("Email", patient.email),
              infoTile("Last Appointment", patient.lastAppointment),
              infoTile(
                "Total Appointments",
                patient.totalAppointments.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Text(value),
        ],
      ),
    );
  }
}
