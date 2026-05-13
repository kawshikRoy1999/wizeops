part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final int companyId;
  final String userName;
  final String password;
  final bool rememberMe;

  const LoginSubmitted({
    required this.companyId,
    required this.userName,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object> get props => [companyId, userName, password, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class PasswordVisibilityToggled extends AuthEvent {
  const PasswordVisibilityToggled();
}
