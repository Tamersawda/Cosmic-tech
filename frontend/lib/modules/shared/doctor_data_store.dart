// lib/modules/shared/doctor_data_store.dart
//
// A simple in-memory singleton that acts as the bridge between the doctor's
// self-registration/onboarding flow and the admin Doctor Management panel.
//
// Doctor onboarding pages WRITE here when the doctor completes their profile.
// Admin Doctor Management READS from here to display pending/approved doctors.
//
// In production this would be replaced by a Firestore / REST backend call.

import 'package:frontend/modules/admin/models/doctor_model.dart';
import 'package:flutter/foundation.dart';

class DoctorDataStore extends ChangeNotifier {
  // Singleton ──────────────────────────────────────────────────────────────────
  DoctorDataStore._();
  static final DoctorDataStore instance = DoctorDataStore._();

  // State ──────────────────────────────────────────────────────────────────────
  final List<DoctorModel> _doctors = [
    // Seed data — mirrors the existing demo doctors
    DoctorModel(
      id: 'D-2041',
      initials: 'PS',
      name: 'Dr. Priya Sharma',
      role: 'Doctor',
      status: 'Approved',
      email: 'priya.sharma@medical.org',
      phone: '+91 98000 11111',
      gender: 'Female',
      dob: '12 Mar 1985',
      address: '14, MG Road',
      city: 'Bangalore',
      state: 'Karnataka',
      country: 'India',
      pincode: '560001',
      specialization: 'Cardiology',
      subSpecialization: 'Interventional Cardiology',
      experience: '12',
      medicalLicense: 'KA-MED-2041',
      council: 'Medical Council of India (MCI)',
      languages: 'English, Hindi, Kannada',
      onlineFee: '800',
      maxPatients: '20',
      slotDuration: '30',
      bufferTime: '10',
      adminVerifiedDate: '01 Jan 2024',
      qualifications: [
        DoctorQualification(
          degree: 'MBBS',
          university: 'Bangalore Medical College',
          year: '2008',
        ),
        DoctorQualification(
          degree: 'MD – Cardiology',
          university: 'AIIMS Delhi',
          year: '2013',
        ),
      ],
    ),
    DoctorModel(
      id: 'D-2042',
      initials: 'VN',
      name: 'Dr. Vikram Nair',
      role: 'Doctor',
      status: 'Approved',
      email: 'vikram.nair@medical.org',
      phone: '+91 98000 22222',
      gender: 'Male',
      dob: '05 Jul 1980',
      address: '7, Park Street',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      pincode: '600001',
      specialization: 'Orthopedics',
      experience: '8',
      medicalLicense: 'TN-MED-2042',
      council: 'Medical Council of India (MCI)',
      languages: 'English, Tamil',
      onlineFee: '600',
    ),
    DoctorModel(
      id: 'D-2043',
      initials: 'SP',
      name: 'Dr. Suresh Patel',
      role: 'Doctor',
      status: 'Pending',
      email: 'suresh.patel@medical.org',
      phone: '+91 98000 33333',
      gender: 'Male',
      dob: '20 Nov 1990',
      address: '22, Ring Road',
      city: 'Ahmedabad',
      state: 'Gujarat',
      country: 'India',
      pincode: '380001',
      specialization: 'Dermatology',
      experience: '5',
      medicalLicense: 'GJ-MED-2043',
      council: 'Medical Council of India (MCI)',
      languages: 'English, Gujarati',
      onlineFee: '500',
    ),
  ];

  // Public API ─────────────────────────────────────────────────────────────────

  List<DoctorModel> get all => List.unmodifiable(_doctors);

  List<DoctorModel> get pending =>
      _doctors.where((d) => d.status == 'Pending').toList();

  List<DoctorModel> get approved =>
      _doctors.where((d) => d.status == 'Approved').toList();

  List<DoctorModel> get rejected =>
      _doctors.where((d) => d.status == 'Rejected').toList();

  /// Called by admin to approve a doctor.
  /// Only Approved doctors are visible in the user-facing app.
  void approveDoctor(String id, {String? note, String? verifiedDate}) {
    final idx = _doctors.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    _doctors[idx] = _doctors[idx].copyWith(
      status: 'Approved',
      adminNote: note,
      adminVerifiedDate: verifiedDate ?? _doctors[idx].adminVerifiedDate,
    );
    notifyListeners();
  }

  /// Called by admin to reject a doctor with an optional reason.
  void rejectDoctor(String id, {String? note}) {
    final idx = _doctors.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    _doctors[idx] = _doctors[idx].copyWith(status: 'Rejected', adminNote: note);
    notifyListeners();
  }

  /// Called by admin to set a doctor back to pending (undo approve/reject).
  void setPending(String id) {
    final idx = _doctors.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    _doctors[idx] = _doctors[idx].copyWith(status: 'Pending');
    notifyListeners();
  }

  /// Called by admin after editing fields in the review panel.
  void updateDoctor(DoctorModel updated) {
    final idx = _doctors.indexWhere((d) => d.id == updated.id);
    if (idx == -1) {
      _doctors.insert(0, updated);
    } else {
      _doctors[idx] = updated;
    }
    notifyListeners();
  }

  /// Called when a new doctor completes self-registration.
  void addDoctor(DoctorModel doctor) {
    _doctors.insert(0, doctor.copyWith(status: 'Pending'));
    notifyListeners();
  }

  /// Returns only the doctors that are Approved — the user app queries this.
  List<DoctorModel> get liveForUserApp => approved;

  DoctorModel? findById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
