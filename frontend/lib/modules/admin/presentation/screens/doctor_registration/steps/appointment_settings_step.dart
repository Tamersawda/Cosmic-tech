import 'package:frontend/modules/admin/presentation/controllers/registration_controller.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class AppointmentSettingsStep extends StatefulWidget {
  final RegistrationController controller;

  const AppointmentSettingsStep({super.key, required this.controller});

  @override
  State<AppointmentSettingsStep> createState() =>
      _AppointmentSettingsStepState();
}

class _AppointmentSettingsStepState extends State<AppointmentSettingsStep> {
  String? selectedSlot;

  Widget slotTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Appointment Slot Duration",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Row(
            children: [
              /// 15 Minutes
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSlot = "15";
                      widget.controller.slotDuration.text = "15";
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),

                    decoration: BoxDecoration(
                      color: selectedSlot == "15"
                          ? AppColors.primaryColor
                          : Colors.transparent,

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: selectedSlot == "15"
                              ? Colors.white
                              : Colors.black54,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "15 Mins",
                          style: TextStyle(
                            color: selectedSlot == "15"
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// 30 Minutes
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSlot = "50";
                      widget.controller.slotDuration.text = "50";
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),

                    decoration: BoxDecoration(
                      color: selectedSlot == "50"
                          ? AppColors.primaryColor
                          : Colors.transparent,

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: selectedSlot == "50"
                              ? Colors.white
                              : Colors.black54,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "50 Mins",
                          style: TextStyle(
                            color: selectedSlot == "50"
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Appointment Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          const Text(
            "Configure appointment limits and scheduling preferences.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          /// Maximum Patients
          AdminTextField(
            topLabel: "Maximum Patients Per Day",
            label: "Enter Maximum Patients",
            controller: widget.controller.maxPatients,
          ),

          const SizedBox(height: 20),

          /// Slot Duration Tabs
          slotTabs(),

          const SizedBox(height: 20),

          /// Buffer Time
          AdminTextField(
            topLabel: "Buffer Time Between Appointments",
            label: "Enter Buffer Time (minutes)",
            controller: widget.controller.bufferTime,
          ),
        ],
      ),
    );
  }
}
