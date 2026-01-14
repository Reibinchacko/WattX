class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final double budgetLimit;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.budgetLimit = 100.0,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      budgetLimit: (map['budgetLimit'] ?? 100.0).toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'budgetLimit': budgetLimit,
      'isActive': isActive,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
}
