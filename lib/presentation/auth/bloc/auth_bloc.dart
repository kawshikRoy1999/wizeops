import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordVisible: state.isPasswordVisible));

    final result = await loginUseCase(
      LoginParams(
        companyId: event.companyId,
        userName: event.userName,
        password: event.password,
        rememberMe: event.rememberMe,
      ),
    );

    result.fold(
      (failure) => emit(
        AuthFailure(
          message: failure.message,
          isPasswordVisible: state.isPasswordVisible,
        ),
      ),
      (user) => emit(
        AuthSuccess(
          user: user,
          isPasswordVisible: state.isPasswordVisible,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthInitial());
  }

  void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    final current = state;
    if (current is AuthInitial) {
      emit(AuthInitial(isPasswordVisible: !current.isPasswordVisible));
    } else if (current is AuthFailure) {
      emit(AuthFailure(
        message: current.message,
        isPasswordVisible: !current.isPasswordVisible,
      ));
    }
  }
}
