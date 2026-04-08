import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class UserHealthInformationPage extends StatefulWidget {
  const UserHealthInformationPage({super.key});

  @override
  State<UserHealthInformationPage> createState() =>
      _UserHealthInformationPageState();
}

class _UserHealthInformationPageState extends State<UserHealthInformationPage> {
  String _bloodGroup = 'O+';
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '70');
  bool _isSaving = false;

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final List<Map<String, dynamic>> _conditions = [
    {'label': 'Anxiety Disorder', 'selected': true},
    {'label': 'Depression', 'selected': false},
    {'label': 'PTSD', 'selected': false},
    {'label': 'Bipolar Disorder', 'selected': false},
    {'label': 'OCD', 'selected': false},
    {'label': 'ADHD', 'selected': true},
    {'label': 'Insomnia', 'selected': false},
    {'label': 'Panic Disorder', 'selected': false},
  ];

  final List<Map<String, dynamic>> _allergies = [
    {'label': 'Penicillin', 'selected': false},
    {'label': 'Aspirin', 'selected': true},
    {'label': 'Latex', 'selected': false},
    {'label': 'Pollen', 'selected': false},
    {'label': 'None', 'selected': false},
  ];

  final List<Map<String, dynamic>> _medications = [
    {'name': 'Sertraline 50mg', 'frequency': 'Once daily', 'active': true},
    {'name': 'Clonazepam 0.5mg', 'frequency': 'As needed', 'active': false},
  ];

  final _medNameCtrl = TextEditingController();
  final _medFreqCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _medNameCtrl.dispose();
    _medFreqCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Health information saved'),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, hPad, isMobile)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Vitals ──
                _sectionLabel('Vitals'),
                const SizedBox(height: 12),
                _buildVitalsCard(isMobile),
                const SizedBox(height: 20),

                // ── Conditions ──
                _sectionLabel('Mental Health Conditions'),
                const SizedBox(height: 12),
                _buildChipGroup(_conditions),
                const SizedBox(height: 20),

                // ── Allergies ──
                _sectionLabel('Known Allergies'),
                const SizedBox(height: 12),
                _buildChipGroup(_allergies),
                const SizedBox(height: 20),

                // ── Medications ──
                _sectionLabel('Current Medications'),
                const SizedBox(height: 12),
                _buildMedicationsSection(isMobile),
                const SizedBox(height: 28),

                // ── Save ──
                _buildSaveButton(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPad, bool isMobile) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        MediaQuery.of(context).padding.top + 14,
        hPad,
        18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Information',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your medical profile',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Blood group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bloodtype_rounded,
                    size: 18,
                    color: AppColors.dangerRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                    items: _bloodGroups
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setState(() => _bloodGroup = v!),
                    dropdownColor: AppColors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 64,
            color: AppColors.borderColor,
          ),
          // Height & Weight row
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.height_rounded,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_rounded,
                          size: 18,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          final selected = item['selected'] as bool;
          return GestureDetector(
            onTap: () => setState(() => item['selected'] = !selected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : AppColors.bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                ),
              ),
              child: Text(
                item['label'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.labelColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationsSection(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ..._medications.asMap().entries.map((e) {
            final i = e.key;
            final med = e.value;
            final isLast = i == _medications.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          size: 18,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med['name'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            Text(
                              med['frequency'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: med['active'] as bool,
                        onChanged: (v) => setState(() => med['active'] = v),
                        activeThumbColor: AppColors.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 64,
                    color: AppColors.borderColor,
                  ),
              ],
            );
          }),
          const Divider(height: 1, thickness: 1, color: AppColors.borderColor),
          // Add medication row
          GestureDetector(
            onTap: () => _showAddMedicationSheet(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Medication',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Add Medication',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _medNameCtrl,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                filled: true,
                fillColor: AppColors.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medFreqCtrl,
              decoration: InputDecoration(
                labelText: 'Frequency (e.g. Once daily)',
                filled: true,
                fillColor: AppColors.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_medNameCtrl.text.isNotEmpty) {
                  setState(() {
                    _medications.add({
                      'name': _medNameCtrl.text,
                      'frequency': _medFreqCtrl.text.isEmpty
                          ? 'As prescribed'
                          : _medFreqCtrl.text,
                      'active': true,
                    });
                    _medNameCtrl.clear();
                    _medFreqCtrl.clear();
                  });
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _save,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.mutedText,
      letterSpacing: 1.1,
    ),
  );
}
