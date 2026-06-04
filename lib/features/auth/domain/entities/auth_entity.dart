import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String username;
  final String? password;
  final String? avatar;

  const AuthEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.username,
    this.password,
    this.avatar,
  });

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
