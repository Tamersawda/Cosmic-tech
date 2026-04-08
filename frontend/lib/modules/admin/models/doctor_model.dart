// lib/modules/admin/models/doctor_model.dart

/// Represents one qualification entry from the onboarding Qualifications step.
class DoctorQualification {
  final String degree;
  final String university;
  final String year;

  /// Local file path or name of the uploaded certificate.
  final String? certificateFile;

  const DoctorQualification({
    required this.degree,
    required this.university,
    required this.year,
    this.certificateFile,
  });

  DoctorQualification copyWith({
    String? degree,
    String? university,
    String? year,
    String? certificateFile,
  }) {
    return DoctorQualification(
      degree: degree ?? this.degree,
      university: university ?? this.university,
      year: year ?? this.year,
      certificateFile: certificateFile ?? this.certificateFile,
    );
  }

  Map<String, dynamic> toMap() => {
    'degree': degree,
    'university': university,
    'year': year,
    'certificateFile': certificateFile,
  };
}

/// Weekly availability slot for one day.
class DoctorDaySchedule {
  final bool enabled;
  final String startTime;
  final String endTime;

  const DoctorDaySchedule({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  DoctorDaySchedule copyWith({
    bool? enabled,
    String? startTime,
    String? endTime,
  }) {
    return DoctorDaySchedule(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Full doctor profile — written by the doctor during onboarding,
/// read (and approved/rejected) by the admin.
class DoctorModel {
  // ── Identity (used for table display) ──────────────────────────────────────
  final String id;
  final String initials;
  final String name;
  final String role;
  final String status; // "Pending" | "Approved" | "Rejected"

  // ── Basic Information ───────────────────────────────────────────────────────
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  /// Local path to the profile photo.
  final String? profilePhotoPath;

  // ── Professional Details ────────────────────────────────────────────────────
  final String specialization;
  final String subSpecialization;
  final String experience;
  final String medicalLicense;
  final String council;
  final String languages;

  // ── Qualifications ──────────────────────────────────────────────────────────
  final List<DoctorQualification> qualifications;

  // ── Consultation Settings ───────────────────────────────────────────────────
  final String onlineFee;

  // ── Appointment Settings ────────────────────────────────────────────────────
  final String maxPatients;
  final String slotDuration;
  final String bufferTime;

  // ── Identity Verification ───────────────────────────────────────────────────
  final String? governmentIdFile;
  final String? medicalLicenseFile;
  final String? selfieFile;
  final String adminVerifiedDate;

  // ── Availability ────────────────────────────────────────────────────────────
  final Map<String, DoctorDaySchedule> weeklySchedule;
  final String timezone;

  // ── Admin notes (set during review) ────────────────────────────────────────
  final String? adminNote;

  const DoctorModel({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.status,
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.dob = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
    this.profilePhotoPath,
    this.specialization = '',
    this.subSpecialization = '',
    this.experience = '',
    this.medicalLicense = '',
    this.council = '',
    this.languages = '',
    this.qualifications = const [],
    this.onlineFee = '',
    this.maxPatients = '',
    this.slotDuration = '',
    this.bufferTime = '',
    this.governmentIdFile,
    this.medicalLicenseFile,
    this.selfieFile,
    this.adminVerifiedDate = '',
    this.weeklySchedule = const {},
    this.timezone = '',
    this.adminNote,
  });

  DoctorModel copyWith({
    String? id,
    String? initials,
    String? name,
    String? role,
    String? status,
    String? email,
    String? phone,
    String? gender,
    String? dob,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? profilePhotoPath,
    String? specialization,
    String? subSpecialization,
    String? experience,
    String? medicalLicense,
    String? council,
    String? languages,
    List<DoctorQualification>? qualifications,
    String? onlineFee,
    String? maxPatients,
    String? slotDuration,
    String? bufferTime,
    String? governmentIdFile,
    String? medicalLicenseFile,
    String? selfieFile,
    String? adminVerifiedDate,
    Map<String, DoctorDaySchedule>? weeklySchedule,
    String? timezone,
    String? adminNote,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      specialization: specialization ?? this.specialization,
      subSpecialization: subSpecialization ?? this.subSpecialization,
      experience: experience ?? this.experience,
      medicalLicense: medicalLicense ?? this.medicalLicense,
      council: council ?? this.council,
      languages: languages ?? this.languages,
      qualifications: qualifications ?? this.qualifications,
      onlineFee: onlineFee ?? this.onlineFee,
      maxPatients: maxPatients ?? this.maxPatients,
      slotDuration: slotDuration ?? this.slotDuration,
      bufferTime: bufferTime ?? this.bufferTime,
      governmentIdFile: governmentIdFile ?? this.governmentIdFile,
      medicalLicenseFile: medicalLicenseFile ?? this.medicalLicenseFile,
      selfieFile: selfieFile ?? this.selfieFile,
      adminVerifiedDate: adminVerifiedDate ?? this.adminVerifiedDate,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      timezone: timezone ?? this.timezone,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}
