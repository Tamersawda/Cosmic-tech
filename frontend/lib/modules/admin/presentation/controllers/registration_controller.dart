import 'package:frontend/modules/admin/presentation/models/doctor_model.dart';
import 'package:flutter/material.dart';

class RegistrationController {
  // ── Basic Information ───────────────────────────────────────────
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final gender = TextEditingController();
  final dob = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final pincode = TextEditingController();

  /// Local path to the picked profile photo.
  String? profilePhotoPath;

  // ── Professional Details ────────────────────────────────────────
  final specialization = TextEditingController();
  final subSpecialization = TextEditingController();
  final experience = TextEditingController();
  final medicalLicense = TextEditingController();
  final council = TextEditingController();
  final languages = TextEditingController();

  // ── Consultation ────────────────────────────────────────────────
  final onlineFee = TextEditingController();
  final offlineFee = TextEditingController(); // ← kept from your original
  final emergencyFee = TextEditingController(); // ← kept from your original

  // ── Appointment Settings ────────────────────────────────────────
  final maxPatients = TextEditingController();
  final slotDuration = TextEditingController();
  final bufferTime = TextEditingController();

  // ── Identity Verification ───────────────────────────────────────
  final adminVerifiedDate = TextEditingController();

  /// File names set by IdentityVerificationStep.
  String? governmentIdFile;
  String? medicalLicenseFile;
  String? selfieFile;

  // ── Qualifications ──────────────────────────────────────────────
  // Replaces the old single degree/university/year controllers.
  // QualificationsStep writes here via _syncToController().
  List<DoctorQualification> qualifications = [];

  // ── Builds the full model for DoctorDataStore ───────────────────
  DoctorModel buildDoctorModel() {
    final name = fullName.text.trim();
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    return DoctorModel(
      id: 'D-${DateTime.now().millisecondsSinceEpoch}',
      initials: initials.isNotEmpty ? initials : 'DR',
      name: name.isNotEmpty ? name : 'Unknown Doctor',
      role: 'Doctor',
      status: 'Pending',
      email: email.text.trim(),
      phone: phone.text.trim(),
      gender: gender.text.trim(),
      dob: dob.text.trim(),
      address: address.text.trim(),
      city: city.text.trim(),
      state: state.text.trim(),
      country: country.text.trim(),
      pincode: pincode.text.trim(),
      profilePhotoPath: profilePhotoPath,
      specialization: specialization.text.trim(),
      subSpecialization: subSpecialization.text.trim(),
      experience: experience.text.trim(),
      medicalLicense: medicalLicense.text.trim(),
      council: council.text.trim(),
      languages: languages.text.trim(),
      qualifications: qualifications,
      onlineFee: onlineFee.text.trim(),
      maxPatients: maxPatients.text.trim(),
      slotDuration: slotDuration.text.trim(),
      bufferTime: bufferTime.text.trim(),
      governmentIdFile: governmentIdFile,
      medicalLicenseFile: medicalLicenseFile,
      selfieFile: selfieFile,
      adminVerifiedDate: adminVerifiedDate.text.trim(),
    );
  }

  // ── Reset ───────────────────────────────────────────────────────
  void reset() {
    for (final ctrl in _allControllers) {
      ctrl.clear();
    }
    profilePhotoPath = null;
    governmentIdFile = null;
    medicalLicenseFile = null;
    selfieFile = null;
    qualifications = [];
  }

  // ── Dispose ─────────────────────────────────────────────────────
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.dispose();
    }
  }

  List<TextEditingController> get _allControllers => [
    fullName,
    email,
    phone,
    password,
    gender,
    dob,
    address,
    city,
    state,
    country,
    pincode,
    specialization,
    subSpecialization,
    experience,
    medicalLicense,
    council,
    languages,
    onlineFee,
    offlineFee,
    emergencyFee,
    maxPatients,
    slotDuration,
    bufferTime,
    adminVerifiedDate,
  ];
}
