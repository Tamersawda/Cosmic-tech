import 'package:frontend/modules/user/screens/doctors/step_connector.dart';
import 'package:frontend/modules/user/screens/doctors/step_node.dart';
import 'package:frontend/modules/user/screens/doctors/steps/appointments_selection_step.dart';
import 'package:frontend/modules/user/screens/doctors/steps/overview_selection_step.dart';
import 'package:frontend/modules/user/screens/doctors/steps/package_selection_step.dart';
import 'package:frontend/modules/user/screens/doctors/steps/payment_selection_step.dart';
import 'package:frontend/modules/user/screens/doctors/steps/service_selection_step.dart';
import 'package:frontend/modules/user/screens/doctors/steps/your_information_step.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class DoctorBookingPage extends StatefulWidget {
  final Map<String, dynamic> doc;

  const DoctorBookingPage({super.key, required this.doc});

  @override
  State<DoctorBookingPage> createState() => _DoctorBookingPageState();
}

class _DoctorBookingPageState extends State<DoctorBookingPage> {
  int _currentStep = 0;

  // Booking state
  String? _selectedService;
  String? _selectedPackage;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _steps = [
    'Service Selection',
    'Package',
    'Appointments',
    'Overview',
    'Verification',
    'Payments',
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step submit
      _showSuccessDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    final nav = Navigator.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your appointment with ${widget.doc['name']} is confirmed for ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year} at $_selectedTime.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  nav.pop(); // Pop dialog
                  nav.pop(); // Pop booking page
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNextEnabled() {
    if (_currentStep == 0) return _selectedService != null;
    if (_currentStep == 1) return _selectedPackage != null;
    if (_currentStep == 2) {
      return _selectedDate != null && _selectedTime != null;
    }
    return true; // Overview onwards shouldn't be blocked artificially for this mock
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: _prevStep,
        ),
        title: Text(
          _steps[_currentStep],
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stepper Indicator
          _buildTopStepper(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: Container(
                  width: isMobile ? double.infinity : 600,
                  constraints: const BoxConstraints(minHeight: 400),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: isMobile ? double.infinity : 600,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isNextEnabled() ? _nextStep : null,
                  child: Text(
                    _currentStep == _steps.length - 1
                        ? 'Make Payment'
                        : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isNextEnabled()
                          ? Colors.white
                          : AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP STEPPER ───────────────────────────────────────────────
  Widget _buildTopStepper() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_steps.length, (index) {
            final active = index == _currentStep;
            final past = index < _currentStep;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StepNode(
                  index: index,
                  label: _steps[index],
                  active: active,
                  past: past,
                ),
                if (index != _steps.length - 1) StepConnector(past: past),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ─── STEP DISPATCHER ───────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ServiceSelectionStep(
          selectedService: _selectedService,
          onServiceChanged: (val) {
            setState(() {
              _selectedService = val;
            });
          },
        );
      case 1:
        return PackageSelectionStep(
          selectedService: _selectedService ?? 'Service',
          fee: widget.doc['fee'],
          selectedPackage: _selectedPackage,
          onPackageChanged: (val) {
            setState(() {
              _selectedPackage = val;
            });
          },
        );
      case 2:
        return AppointmentsSelectionStep(
          selectedService: _selectedService,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateChanged: (val) {
            setState(() {
              _selectedDate = val;
              _selectedTime = null;
            });
          },
          onTimeChanged: (val) {
            setState(() {
              _selectedTime = val;
            });
          },
        );
      case 3:
        return OverviewSelectionStep(
          selectedPackage: _selectedPackage,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          doctorName: widget.doc['name'],
        );
      case 4:
        return const YourInformationStep();
      case 5:
        return PaymentSelectionStep(fee: widget.doc['fee']);
      default:
        return const SizedBox();
    }
  }
}
