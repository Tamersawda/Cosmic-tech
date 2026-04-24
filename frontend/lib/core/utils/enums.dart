enum Admin {
  dashboard,
  patients,
  doctors,
  notifications,
  settings,
  userRegistration,
  appointments,
  contentManagement,
  reviewsAndRatings,
  supportAndComplaints,
  trainingModules,
  quizQuestionsManagement,
}

enum UserRole {
  user,
  doctor,
  admin;

  /// Maps the enum to the role string expected by the backend API.
  /// Backend accepts 'client' or 'doctor' — not 'user'.
  String get apiValue => switch (this) {
    UserRole.user => 'client',
    UserRole.doctor => 'doctor',
    UserRole.admin => 'admin',
  };
}
