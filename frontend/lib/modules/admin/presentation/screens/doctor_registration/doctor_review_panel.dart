// lib/modules/admin/screens/doctor_review_panel.dart
//
// Full-screen panel that the admin sees when they click "Review" / "Edit" on a doctor row.
// Shows all sections from the doctor's onboarding in read-only accordion cards,
// plus document viewers, and Approve / Reject / Note actions at the bottom.

import 'dart:io';
import 'package:frontend/modules/admin/presentation/models/doctor_model.dart';
import 'package:frontend/modules/admin/presentation/widgets/doctor/admin_document_viewer.dart';
import 'package:frontend/modules/shared/doctor_data_store.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorReviewPanel extends StatefulWidget {
  final DoctorModel doctor;

  /// Called after status changes so the parent list can rebuild.
  final VoidCallback? onStatusChanged;

  /// Called when the user presses back. When provided, renders inline
  /// (no Navigator.pop) so the admin sidebar stays visible.
  final VoidCallback? onBack;

  const DoctorReviewPanel({
    super.key,
    required this.doctor,
    this.onStatusChanged,
    this.onBack,
  });

  @override
  State<DoctorReviewPanel> createState() => _DoctorReviewPanelState();
}

class _DoctorReviewPanelState extends State<DoctorReviewPanel> {
  late DoctorModel _doctor;
  final _noteCtrl = TextEditingController();
  String? _verifiedDate;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
    _noteCtrl.text = widget.doctor.adminNote ?? '';
    _verifiedDate = widget.doctor.adminVerifiedDate.isNotEmpty
        ? widget.doctor.adminVerifiedDate
        : null;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  // Closes the review panel – works both inline (onBack) and as a pushed route.
  void _close() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  void _approve() {
    _pickVerifiedDate().then((_) {
      DoctorDataStore.instance.approveDoctor(
        _doctor.id,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        verifiedDate: _verifiedDate,
      );
      widget.onStatusChanged?.call();
      _close();
      _showSnack('✅ ${_doctor.name} has been Approved and is now live.');
    });
  }

  void _reject() {
    DoctorDataStore.instance.rejectDoctor(
      _doctor.id,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
    );
    widget.onStatusChanged?.call();
    _close();
    _showSnack('❌ ${_doctor.name} has been Rejected.');
  }

  void _setPending() {
    DoctorDataStore.instance.setPending(_doctor.id);
    widget.onStatusChanged?.call();
    _close();
  }

  Future<void> _pickVerifiedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _verifiedDate = DateFormat('dd MMM yyyy').format(date);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            _avatarCircle(_doctor.initials, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _doctor.id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _StatusBadge(status: _doctor.status),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: Row(
        children: [
          // ── Left scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _SectionAccordion(
                    title: 'Basic Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildProfilePhotoRow(),
                      const SizedBox(height: 20),
                      _twoCol(
                        _infoTile('Full Name', _doctor.name),
                        _infoTile('Email', _doctor.email),
                      ),
                      _twoCol(
                        _infoTile('Phone', _doctor.phone),
                        _infoTile('Gender', _doctor.gender),
                      ),
                      _twoCol(
                        _infoTile('Date of Birth', _doctor.dob),
                        _infoTile('Pincode', _doctor.pincode),
                      ),
                      _infoTile('Address', _doctor.address),
                      _twoCol(
                        _infoTile('City', _doctor.city),
                        _infoTile('State', _doctor.state),
                      ),
                      _twoCol(
                        _infoTile('Country', _doctor.country),
                        const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionAccordion(
                    title: 'Professional Details',
                    icon: Icons.work_outline,
                    children: [
                      _twoCol(
                        _infoTile('Specialization', _doctor.specialization),
                        _infoTile(
                          'Sub-Specialization',
                          _doctor.subSpecialization,
                        ),
                      ),
                      _twoCol(
                        _infoTile('Experience', '${_doctor.experience} years'),
                        _infoTile('Medical License', _doctor.medicalLicense),
                      ),
                      _twoCol(
                        _infoTile('Medical Council', _doctor.council),
                        _infoTile('Languages', _doctor.languages),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionAccordion(
                    title: 'Qualifications',
                    icon: Icons.school_outlined,
                    children: _doctor.qualifications.isEmpty
                        ? [_emptyNote('No qualifications added.')]
                        : _doctor.qualifications.asMap().entries.map((e) {
                            final q = e.value;
                            return _QualificationTile(
                              index: e.key + 1,
                              qualification: q,
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _SectionAccordion(
                    title: 'Consultation & Appointment Settings',
                    icon: Icons.calendar_today_outlined,
                    children: [
                      _twoCol(
                        _infoTile(
                          'Online Consultation Fee',
                          _doctor.onlineFee.isNotEmpty
                              ? '₹${_doctor.onlineFee}'
                              : '—',
                        ),
                        _infoTile('Max Patients / Day', _doctor.maxPatients),
                      ),
                      _twoCol(
                        _infoTile(
                          'Slot Duration',
                          _doctor.slotDuration.isNotEmpty
                              ? '${_doctor.slotDuration} mins'
                              : '—',
                        ),
                        _infoTile(
                          'Buffer Time',
                          _doctor.bufferTime.isNotEmpty
                              ? '${_doctor.bufferTime} mins'
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionAccordion(
                    title: 'Weekly Availability',
                    icon: Icons.schedule_outlined,
                    children: _doctor.weeklySchedule.isEmpty
                        ? [_emptyNote('Availability not configured yet.')]
                        : _doctor.weeklySchedule.entries.map((e) {
                            final day = e.key;
                            final slot = e.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  slot.enabled
                                      ? Text(
                                          '${slot.startTime} – ${slot.endTime}',
                                          style: const TextStyle(fontSize: 13),
                                        )
                                      : const Text(
                                          'Unavailable',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _SectionAccordion(
                    title: 'Identity Documents',
                    icon: Icons.verified_user_outlined,
                    initiallyExpanded: true,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AdminDocumentViewer(
                              label: 'Government ID Proof',
                              filePath: _doctor.governmentIdFile,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AdminDocumentViewer(
                              label: 'Medical License',
                              filePath: _doctor.medicalLicenseFile,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AdminDocumentViewer(
                        label: 'Profile Selfie Verification',
                        filePath: _doctor.selfieFile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── Right action panel ─────────────────────────────────────────────
          _ActionSidebar(
            doctor: _doctor,
            noteCtrl: _noteCtrl,
            verifiedDate: _verifiedDate,
            onApprove: _approve,
            onReject: _reject,
            onSetPending: _setPending,
          ),
        ],
      ),
    );
  }

  // ── Helper builders ──────────────────────────────────────────────────────────

  Widget _buildProfilePhotoRow() {
    final path = _doctor.profilePhotoPath;
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryColor.withOpacity(0.12),
            backgroundImage: path != null && File(path).existsSync()
                ? FileImage(File(path))
                : null,
            child: path == null
                ? Text(
                    _doctor.initials,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            _doctor.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            _doctor.specialization.isNotEmpty
                ? _doctor.specialization
                : 'No specialization',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoCol(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  Widget _emptyNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF94A3B8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _avatarCircle(String initials, {double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

// ── Section accordion ─────────────────────────────────────────────────────────

class _SectionAccordion extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _SectionAccordion({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<_SectionAccordion> createState() => _SectionAccordionState();
}

class _SectionAccordionState extends State<_SectionAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Qualification tile ────────────────────────────────────────────────────────

class _QualificationTile extends StatelessWidget {
  final int index;
  final DoctorQualification qualification;

  const _QualificationTile({required this.index, required this.qualification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.primaryColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  qualification.degree,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                qualification.year,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            qualification.university,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          if (qualification.certificateFile != null) ...[
            const SizedBox(height: 10),
            AdminDocumentViewer(
              label: 'Certificate',
              filePath: qualification.certificateFile,
              height: 100,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Right action sidebar ──────────────────────────────────────────────────────

class _ActionSidebar extends StatefulWidget {
  final DoctorModel doctor;
  final TextEditingController noteCtrl;
  final String? verifiedDate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSetPending;

  const _ActionSidebar({
    required this.doctor,
    required this.noteCtrl,
    required this.verifiedDate,
    required this.onApprove,
    required this.onReject,
    required this.onSetPending,
  });

  @override
  State<_ActionSidebar> createState() => _ActionSidebarState();
}

class _ActionSidebarState extends State<_ActionSidebar> {
  @override
  Widget build(BuildContext context) {
    final status = widget.doctor.status;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REVIEW ACTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),

            // Current status
            _StatusBadge(status: status),

            const SizedBox(height: 20),

            // Admin note
            const Text(
              'Admin Note',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: widget.noteCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a note for this doctor...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCBD5E1),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            if (status == 'Pending') ...[
              _ActionButton(
                label: 'Approve Doctor',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16A34A),
                onTap: widget.onApprove,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Reject Doctor',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFDC2626),
                onTap: widget.onReject,
              ),
            ] else if (status == 'Approved') ...[
              _infoChip(
                Icons.check_circle,
                'Live in user app',
                const Color(0xFF16A34A),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Revoke Approval',
                icon: Icons.undo,
                color: const Color(0xFFEA580C),
                onTap: widget.onSetPending,
              ),
            ] else if (status == 'Rejected') ...[
              _infoChip(
                Icons.cancel,
                'Not visible in user app',
                const Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Move to Pending',
                icon: Icons.refresh,
                color: AppColors.primaryColor,
                onTap: widget.onSetPending,
              ),
            ],

            const SizedBox(height: 24),

            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            const Text(
              'USER APP VISIBILITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: status == 'Approved'
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: status == 'Approved'
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFED7AA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'Approved'
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 18,
                    color: status == 'Approved'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status == 'Approved'
                          ? 'This doctor is visible to patients.'
                          : 'Not visible until approved by admin.',
                      style: TextStyle(
                        fontSize: 12,
                        color: status == 'Approved'
                            ? const Color(0xFF166534)
                            : const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _bg => switch (status) {
    'Approved' => const Color(0xFFF0FDF4),
    'Rejected' => const Color(0xFFFEF2F2),
    _ => const Color(0xFFFFFBEB),
  };

  Color get _fg => switch (status) {
    'Approved' => const Color(0xFF16A34A),
    'Rejected' => const Color(0xFFDC2626),
    _ => const Color(0xFFD97706),
  };

  IconData get _icon => switch (status) {
    'Approved' => Icons.check_circle,
    'Rejected' => Icons.cancel,
    _ => Icons.hourglass_empty,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _fg),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}
