// lib/modules/admin/screens/doctor_management.dart

import 'package:frontend/modules/admin/presentation/models/doctor_model.dart';
import 'package:frontend/modules/admin/presentation/screens/doctor_registration/doctor_registration_form.dart';
import 'package:frontend/modules/admin/presentation/screens/doctor_registration/doctor_review_panel.dart';
import 'package:frontend/modules/shared/doctor_data_store.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_page_header.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class DoctorManagement extends StatefulWidget {
  const DoctorManagement({super.key});

  @override
  State<DoctorManagement> createState() => _DoctorManagementState();
}

class _DoctorManagementState extends State<DoctorManagement>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String _searchQuery = '';
  bool _showRegisterDoctor = false;
  DoctorModel? _reviewingDoctor;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    // Rebuild whenever the store changes (approve/reject/add)
    DoctorDataStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    DoctorDataStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  // ── Filtered lists per tab ─────────────────────────────────────────────────

  List<DoctorModel> _filter(List<DoctorModel> src) {
    if (_searchQuery.isEmpty) return src;
    final q = _searchQuery.toLowerCase();
    return src
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialization.toLowerCase().contains(q) ||
              d.id.toLowerCase().contains(q),
        )
        .toList();
  }

  List<DoctorModel> get _pendingList =>
      _filter(DoctorDataStore.instance.pending);
  List<DoctorModel> get _approvedList =>
      _filter(DoctorDataStore.instance.approved);
  List<DoctorModel> get _rejectedList =>
      _filter(DoctorDataStore.instance.rejected);

  // ── Actions ────────────────────────────────────────────────────────────────

  void _openReview(DoctorModel doctor) {
    setState(() => _reviewingDoctor = doctor);
  }

  void _quickApprove(DoctorModel doctor) {
    DoctorDataStore.instance.approveDoctor(doctor.id);
    _showSnack('✅ ${doctor.name} approved');
  }

  void _quickReject(DoctorModel doctor) {
    DoctorDataStore.instance.rejectDoctor(doctor.id);
    _showSnack('❌ ${doctor.name} rejected');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── Inline Doctor Review (keeps sidebar visible) ──────────────────────────
    if (_reviewingDoctor != null) {
      return DoctorReviewPanel(
        doctor: _reviewingDoctor!,
        onStatusChanged: () => setState(() {}),
        onBack: () => setState(() => _reviewingDoctor = null),
      );
    }

    // ── Inline Add Doctor Form ────────────────────────────────────────────────
    if (_showRegisterDoctor) {
      return RegisterDoctorForm(
        onCancel: () => setState(() => _showRegisterDoctor = false),
        onSaveDoctor: (doctor) {
          DoctorDataStore.instance.addDoctor(doctor);
          setState(() => _showRegisterDoctor = false);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────────────────────────────
          AdminPageHeader(
            title: 'Doctor Management',
            subtitle: 'Review, verify, and manage doctor profiles',
            action: ElevatedButton.icon(
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
              onPressed: () => setState(() => _showRegisterDoctor = true),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Doctor',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Search + live badge ──────────────────────────────────────────
          _SearchAndBadgeRow(
            approvedCount: DoctorDataStore.instance.approved.length,
            onSearchChanged: (q) => setState(() => _searchQuery = q),
          ),

          const SizedBox(height: 16),

          // ── Tabs ─────────────────────────────────────────────────────────
          _DoctorTabBar(
            controller: _tabCtrl,
            pendingCount: DoctorDataStore.instance.pending.length,
            approvedCount: DoctorDataStore.instance.approved.length,
            rejectedCount: DoctorDataStore.instance.rejected.length,
          ),

          const SizedBox(height: 20),

          // ── Tab content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _DoctorTable(
                  doctors: _pendingList,
                  emptyMessage: 'No pending doctors.',
                  showQuickActions: true,
                  onReview: _openReview,
                  onApprove: _quickApprove,
                  onReject: _quickReject,
                ),
                _DoctorTable(
                  doctors: _approvedList,
                  emptyMessage: 'No approved doctors yet.',
                  showQuickActions: false,
                  onReview: _openReview,
                ),
                _DoctorTable(
                  doctors: _rejectedList,
                  emptyMessage: 'No rejected doctors.',
                  showQuickActions: false,
                  onReview: _openReview,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search + live badge ────────────────────────────────────────────────────────

class _SearchAndBadgeRow extends StatelessWidget {
  final int approvedCount;
  final ValueChanged<String> onSearchChanged;

  const _SearchAndBadgeRow({
    required this.approvedCount,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AdminTextField(
            onChanged: onSearchChanged,
            hintText: 'Search by name, specialization or ID...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Text(
                '$approvedCount Live in User App',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab bar ────────────────────────────────────────────────────────────────────

class _DoctorTabBar extends StatelessWidget {
  final TabController controller;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const _DoctorTabBar({
    required this.controller,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab(
            'Pending',
            pendingCount,
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
          ),
          _buildTab(
            'Approved',
            approvedCount,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
          ),
          _buildTab(
            'Rejected',
            rejectedCount,
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String label, int count, Color bg, Color fg) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor table ───────────────────────────────────────────────────────────────

class _DoctorTable extends StatelessWidget {
  final List<DoctorModel> doctors;
  final String emptyMessage;
  final bool showQuickActions;
  final ValueChanged<DoctorModel> onReview;
  final ValueChanged<DoctorModel>? onApprove;
  final ValueChanged<DoctorModel>? onReject;

  const _DoctorTable({
    required this.doctors,
    required this.emptyMessage,
    required this.showQuickActions,
    required this.onReview,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Always provide a finite width to SizedBox so Expanded children work
        final double tableWidth =
            (constraints.maxWidth.isFinite && constraints.maxWidth > 900)
            ? constraints.maxWidth
            : 900.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: AdminCardContainer(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row – NOT const so layout reacts to new constraints
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _ColHeader('DOCTOR')),
                        Expanded(flex: 2, child: _ColHeader('SPECIALIZATION')),
                        Expanded(flex: 1, child: _ColHeader('EXP.')),
                        Expanded(flex: 1, child: _ColHeader('FEE')),
                        Expanded(flex: 2, child: _ColHeader('STATUS')),
                        Expanded(flex: 3, child: _ColHeader('ACTIONS')),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Data rows – shrinkWrap so no Expanded needed inside scroll
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (_, i) => _DoctorRow(
                      doctor: doctors[i],
                      showQuickActions: showQuickActions,
                      onReview: () => onReview(doctors[i]),
                      onApprove: onApprove != null
                          ? () => onApprove!(doctors[i])
                          : null,
                      onReject: onReject != null
                          ? () => onReject!(doctors[i])
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;

  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.6,
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  final DoctorModel doctor;
  final bool showQuickActions;
  final VoidCallback onReview;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _DoctorRow({
    required this.doctor,
    required this.showQuickActions,
    required this.onReview,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Doctor name + ID
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _Avatar(initials: doctor.initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        doctor.id,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              doctor.specialization.isNotEmpty ? doctor.specialization : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),

          Expanded(
            flex: 1,
            child: Text(
              doctor.experience.isNotEmpty ? '${doctor.experience} yrs' : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),

          Expanded(
            flex: 1,
            child: Text(
              doctor.onlineFee.isNotEmpty ? '₹${doctor.onlineFee}' : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),

          Expanded(flex: 2, child: _StatusPill(status: doctor.status)),

          // Actions
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Review / Edit
                _SmallButton(
                  label: 'Review',
                  icon: Icons.pageview_outlined,
                  color: AppColors.primaryColor,
                  onTap: onReview,
                ),

                if (showQuickActions) ...[
                  const SizedBox(width: 8),
                  _SmallButton(
                    label: 'Approve',
                    icon: Icons.check,
                    color: const Color(0xFF16A34A),
                    onTap: onApprove,
                  ),
                  const SizedBox(width: 8),
                  _SmallButton(
                    label: 'Reject',
                    icon: Icons.close,
                    color: const Color(0xFFDC2626),
                    onTap: onReject,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _fg),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SmallButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
