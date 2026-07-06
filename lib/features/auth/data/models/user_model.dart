class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['Firstname'] ?? '',
      lastName: json['Lastname'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'Firstname': firstName,
      'Lastname': lastName,
      'phone': phone,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}
