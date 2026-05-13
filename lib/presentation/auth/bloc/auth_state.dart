part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  final bool isPasswordVisible;
  const AuthState({this.isPasswordVisible = false});

  @override
  List<Object?> get props => [isPasswordVisible];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.isPasswordVisible});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.isPasswordVisible});
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  const AuthSuccess({required this.user, super.isPasswordVisible});

  @override
  List<Object?> get props => [user, isPasswordVisible];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message, super.isPasswordVisible});

  @override
  List<Object?> get props => [message, isPasswordVisible];
}
