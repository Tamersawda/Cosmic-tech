class UserModel {
  final String role;
  final String token;
  final String name;
  final String email;

  const UserModel({
    required this.role,
    required this.token,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      role: json['role']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'token': token,
    'name': name,
    'email': email,
  };

  UserModel copyWith({
    String? role,
    String? token,
    String? name,
    String? email,
  }) {
    return UserModel(
      role: role ?? this.role,
      token: token ?? this.token,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() =>
      'UserModel(role: $role, name: $name, email: $email)';
}
