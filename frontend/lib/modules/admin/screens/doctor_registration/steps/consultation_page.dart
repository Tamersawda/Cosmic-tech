import 'package:frontend/modules/admin/controllers/registration_controller.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_page_header.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class ConsultationStep extends StatelessWidget {
  final RegistrationController controller;

  const ConsultationStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminPageHeader(
            title: "Consultation Settings",
            subtitle:
                "Define doctor consultation fees and appointment settings.",
          ),
          const SizedBox(height: 25),
          AdminTextField(
            topLabel: "Online Consultation Fee",
            hintText: "Enter Online Fee",
            controller: controller.onlineFee,
          ),
        ],
      ),
    );
  }
}
