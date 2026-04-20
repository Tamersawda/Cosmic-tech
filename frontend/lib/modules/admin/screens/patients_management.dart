import 'package:frontend/modules/admin/models/patient_model.dart';
import 'package:frontend/modules/admin/screens/patient/patient_details_panel.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_page_header.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class PatientsManagementPage extends StatefulWidget {
  const PatientsManagementPage({super.key});

  @override
  State<PatientsManagementPage> createState() => _PatientsManagementPageState();
}

class _PatientsManagementPageState extends State<PatientsManagementPage> {
  Patient? selectedPatient;

  final List<Patient> patients = [
    Patient(
      name: "Anjali Rao",
      id: "P-5520",
      phone: "+91 98765 43210",
      email: "anjali@email.com",
      lastAppointment: "11 Mar 2026",
      totalAppointments: 8,
    ),
    Patient(
      name: "Rohan Gupta",
      id: "P-5521",
      phone: "+91 87654 32109",
      email: "rohan@email.com",
      lastAppointment: "11 Mar 2026",
      totalAppointments: 3,
    ),
    Patient(
      name: "Meena Iyer",
      id: "P-5522",
      phone: "+91 76543 21098",
      email: "meena@email.com",
      lastAppointment: "10 Mar 2026",
      totalAppointments: 12,
    ),
  ];

  String search = "";

  @override
  Widget build(BuildContext context) {
    final filtered = patients
        .where(
          (p) =>
              p.name.toLowerCase().contains(search.toLowerCase()) ||
              p.email.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();

    /// MOBILE → FULL PAGE DETAILS
    if (Responsive.isMobile(context) && selectedPatient != null) {
      return PatientDetailsPanel(
        patient: selectedPatient!,
        onClose: () {
          setState(() {
            selectedPatient = null;
          });
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const AdminPageHeader(
            title: "Patient Management",
            subtitle: "View patient records, histories, and manage accounts",
          ),

          const SizedBox(height: 20),

          AdminTextField(
            onChanged: (v) {
              setState(() {
                search = v;
              });
            },
            hintText: "Search patients...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Responsive.isDesktop(context)
                ? Row(
                    children: [
                      /// TABLE
                      Expanded(flex: 3, child: buildPatientTable(filtered)),

                      /// DETAILS PANEL
                      if (selectedPatient != null)
                        Expanded(
                          flex: 2,
                          child: PatientDetailsPanel(
                            patient: selectedPatient!,
                            onClose: () {
                              setState(() {
                                selectedPatient = null;
                              });
                            },
                          ),
                        ),
                    ],
                  )
                /// TABLET → REPLACE TABLE WITH DETAILS
                : selectedPatient == null
                ? buildPatientTable(filtered)
                : PatientDetailsPanel(
                    patient: selectedPatient!,
                    onClose: () {
                      setState(() {
                        selectedPatient = null;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPatientTable(List<Patient> patients) {
    return AdminCardContainer(
      padding: EdgeInsets.zero,

      child: Column(
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                const Expanded(flex: 3, child: Text("PATIENT")),

                if (!Responsive.isMobile(context))
                  const Expanded(flex: 3, child: Text("CONTACT")),

                if (Responsive.isDesktop(context))
                  const Expanded(flex: 2, child: Text("LAST APPOINTMENT")),

                const Expanded(flex: 1, child: Text("TOTAL")),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              children: patients.map((p) => patientRow(p)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget patientRow(Patient patient) {
    final bool isSelected = selectedPatient?.id == patient.id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPatient = patient;
        });
      },

      child: Container(
        color: isSelected ? const Color(0xfff1f5f9) : null,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        child: Row(
          children: [
            /// PATIENT
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(patient.name[0]),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          patient.id,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// CONTACT
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.phone),
                    Text(
                      patient.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            /// LAST APPOINTMENT
            if (Responsive.isDesktop(context))
              Expanded(flex: 2, child: Text(patient.lastAppointment)),

            /// TOTAL
            Expanded(
              flex: 1,
              child: Text(
                patient.totalAppointments.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
