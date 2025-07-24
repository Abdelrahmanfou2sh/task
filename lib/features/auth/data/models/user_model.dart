class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String role; // 'customer', 'agent', 'admin', or 'both'

  UserModel({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'],
      phone: map['phone'],
      displayName: map['displayName'],
      role: map['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'role': role,
    };
  }
} 