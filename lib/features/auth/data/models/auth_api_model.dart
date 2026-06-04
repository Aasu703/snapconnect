import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

class AuthApiModel extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String username;
  final String? password;
  final String? avatar;

  const AuthApiModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.username,
    this.password,
    this.avatar,
  });

  // ─── Deserialization ───────────────────────────────────────────────────────

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      username: json['username'] as String,
      password: json['password'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  // ─── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'username': username,
      if (password != null) 'password': password,
      if (avatar != null) 'avatar': avatar,
    };
  }

  // ─── Entity Conversion ─────────────────────────────────────────────────────

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      userId: entity.userId,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      avatar: entity.avatar,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      avatar: avatar,
    );
  }

  // ─── CopyWith ──────────────────────────────────────────────────────────────

  AuthApiModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? username,
    String? password,
    String? avatar,
  }) {
    return AuthApiModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    email,
    fullName,
    phoneNumber,
    username,
    password,
    avatar,
  ];
}
