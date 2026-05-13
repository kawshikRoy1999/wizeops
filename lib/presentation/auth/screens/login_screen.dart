import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  final int _companyId = 0;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          LoginSubmitted(
            companyId: _companyId,
            userName: _userNameController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DashboardScreen(user: state.user),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.statusError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          const AppLogo(),
                          const SizedBox(height: 12),
                          Text(
                            'WizeOps',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBranding,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Restaurant Operations Manager',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textLowEmphasis,
                            ),
                          ),
                          const Spacer(flex: 2),
                          _LoginCard(
                            formKey: _formKey,
                            userNameController: _userNameController,
                            passwordController: _passwordController,
                            rememberMe: _rememberMe,
                            onRememberMeChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                            onSubmit: _submit,
                          ),
                          const Spacer(flex: 3),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '© 2024 Wize Restaurant. All rights reserved.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textLowEmphasis,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.userNameController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textHighEmphasis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Access your operational dashboard',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textLowEmphasis,
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: userNameController,
                label: 'Email / Username',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppTheme.textLowEmphasis,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AppTextField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: !state.isPasswordVisible,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: AppTheme.textLowEmphasis,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const PasswordVisibilityToggled()),
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppTheme.textLowEmphasis,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (val.length < 4) {
                        return 'Password is too short';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: onRememberMeChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textHighEmphasis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: AppTheme.primaryBranding,
                      disabledBackgroundColor:
                          AppTheme.primaryBranding.withOpacity(0.6),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
