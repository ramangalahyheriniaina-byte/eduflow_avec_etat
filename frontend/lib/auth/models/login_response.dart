import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String token;
  final UserModel user;

  LoginResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
