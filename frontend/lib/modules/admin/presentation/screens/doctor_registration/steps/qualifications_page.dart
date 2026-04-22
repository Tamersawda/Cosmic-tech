import 'package:frontend/modules/admin/presentation/controllers/registration_controller.dart';
import 'package:frontend/modules/admin/presentation/models/doctor_model.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class _QualEntry {
  TextEditingController degree = TextEditingController();
  TextEditingController university = TextEditingController();
  TextEditingController year = TextEditingController();
  String? certificate;
}

class QualificationsStep extends StatefulWidget {
  final RegistrationController controller;

  const QualificationsStep({super.key, required this.controller});

  @override
  State<QualificationsStep> createState() => _QualificationsStepState();
}

class _QualificationsStepState extends State<QualificationsStep> {
  final List<_QualEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _addEntry();
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.degree.removeListener(_syncToController);
      e.university.removeListener(_syncToController);
      e.year.removeListener(_syncToController);
      e.degree.dispose();
      e.university.dispose();
      e.year.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    final entry = _QualEntry();
    entry.degree.addListener(_syncToController);
    entry.university.addListener(_syncToController);
    entry.year.addListener(_syncToController);
    setState(() => _entries.add(entry));
    _syncToController();
  }

  void _removeEntry(int index) {
    final e = _entries.removeAt(index);
    e.degree.removeListener(_syncToController);
    e.university.removeListener(_syncToController);
    e.year.removeListener(_syncToController);
    e.degree.dispose();
    e.university.dispose();
    e.year.dispose();
    setState(() {});
    _syncToController();
  }

  void _syncToController() {
    widget.controller.qualifications = _entries
        .map(
          (e) => DoctorQualification(
            degree: e.degree.text.trim(),
            university: e.university.text.trim(),
            year: e.year.text.trim(),
            certificateFile: e.certificate,
          ),
        )
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qualifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add educational and professional qualifications.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Qualification cards
          ...List.generate(_entries.length, (i) {
            final entry = _entries[i];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AdminTextField(
                            topLabel: 'Degree',
                            label: 'Degree',
                            controller: entry.degree,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: AdminTextField(
                            topLabel: 'Year',
                            label: 'Year',
                            controller: entry.year,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _removeEntry(i),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    AdminTextField(
                      topLabel: 'University',
                      label: 'Institution',
                      controller: entry.university,
                    ),
                    const SizedBox(height: 20),

                    // Certificate upload
                    DropTarget(
                      onDragDone: (d) {},
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: entry.certificate == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_upload, size: 28),
                                      SizedBox(height: 6),
                                      Text(
                                        'Drag & Drop Certificate\nor Click to Upload',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.description,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        entry.certificate!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Add button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: _addEntry,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Qualification',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
