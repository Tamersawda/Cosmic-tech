import 'package:frontend/modules/admin/presentation/controllers/registration_controller.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class ProfessionalDetailsStep extends StatelessWidget {
  final RegistrationController controller;

  const ProfessionalDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Professional Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text(
            "Provide specialization and licensing details.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          /// Specialization + Sub-specialization
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  topLabel: "Specialization",
                  label: "Enter Specialization",
                  controller: controller.specialization,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  topLabel: "Sub-specialization",
                  label: "Enter Sub-specialization",
                  controller: controller.subSpecialization,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Experience + Registration Number
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  topLabel: "Years of Experience",
                  label: "Enter Years of Experience",
                  controller: controller.experience,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  topLabel: "Medical Registration Number",
                  label: "Enter Registration Number",
                  controller: controller.medicalLicense,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Medical Council + Languages
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  topLabel: "Medical Council Name",
                  label: "Enter Medical Council Name",
                  controller: controller.council,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  topLabel: "Languages Spoken",
                  label: "Enter Languages",
                  controller: controller.languages,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
