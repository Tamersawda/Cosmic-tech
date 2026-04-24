class UserModel {
  final String userId;
  final String role;
  final String token;
  final String refreshToken;
  final String name;
  final String email;
  final bool isProfileComplete;
  final int onboardingStep;

  const UserModel({
    required this.userId,
    required this.role,
    required this.token,
    required this.refreshToken,
    required this.name,
    required this.email,
    this.isProfileComplete = false,
    this.onboardingStep = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps in { "success": true, "data": { ... } }
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserModel(
      userId: data['userId']?.toString() ?? '',
      role: data['role']?.toString() ?? data['userType']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
      name: data['name']?.toString() ?? data['fullName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      // backend uses is_profile_completed (snake_case)
      isProfileComplete: data['is_profile_completed'] as bool? ?? false,
      onboardingStep: data['onboarding_step'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role,
    'token': token,
    'refreshToken': refreshToken,
    'name': name,
    'email': email,
    'is_profile_completed': isProfileComplete,
    'onboarding_step': onboardingStep,
  };

  UserModel copyWith({
    String? userId,
    String? role,
    String? token,
    String? refreshToken,
    String? name,
    String? email,
    bool? isProfileComplete,
    int? onboardingStep,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      name: name ?? this.name,
      email: email ?? this.email,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      onboardingStep: onboardingStep ?? this.onboardingStep,
    );
  }

  @override
  String toString() =>
      'UserModel(userId: $userId, role: $role, '
      'name: $name, email: $email, '
      'isProfileComplete: $isProfileComplete, '
      'onboardingStep: $onboardingStep)';
}
