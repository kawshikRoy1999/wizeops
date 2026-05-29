import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _rememberMe = false;
  final int _companyId = 0;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 540));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Login screen is always light — always use dark status bar icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(LoginSubmitted(
          companyId: _companyId,
          userName: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          rememberMe: _rememberMe,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Login screen is always light regardless of app theme
    const isDark = false;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => DashboardScreen(user: state.user)));
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      child: Theme(
        data: AppTheme.lightTheme,
        child: Scaffold(
          backgroundColor: const Color(0xFF35587A),
          body: Stack(
            children: [
              // ── Restaurant atmosphere background ──
              const _RestaurantBackground(),
              // ── Content ──
              SafeArea(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _BrandMark(),
                            const SizedBox(height: 36),
                            _LoginCard(
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passCtrl: _passCtrl,
                              emailFocus: _emailFocus,
                              passFocus: _passFocus,
                              rememberMe: _rememberMe,
                              isDark: isDark,
                              onRememberChanged: (v) =>
                                  setState(() => _rememberMe = v),
                              onSubmit: _submit,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              '© ${DateTime.now().year} Wize Restaurant',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // Theme
    );
  }
}

// ─────────────────────────────────────────
// Brand Mark
// ─────────────────────────────────────────
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo with amber glow ring
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.actionAccent.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.actionAccent.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text('W',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  )),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'WizeOps',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 1,
              color: AppTheme.actionAccent.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'Restaurant Operations',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 1,
              color: AppTheme.actionAccent.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Login Card
// ─────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final bool rememberMe;
  final bool isDark;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.rememberMe,
    required this.isDark,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: AppTheme.darkBorder)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF2C3E50).withOpacity(0.07),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Amber accent bar ──
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.actionAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome Back',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.darkTextHigh
                    : AppTheme.textHighEmphasis,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Sign in to your account',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkTextLow
                    : AppTheme.textLowEmphasis,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 26),

            _Field(
              ctrl: emailCtrl,
              focus: emailFocus,
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              isDark: isDark,
              onSubmitted: (_) => passFocus.requestFocus(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => _Field(
                ctrl: passCtrl,
                focus: passFocus,
                label: 'Password',
                hint: 'Enter your password',
                obscure: !state.isPasswordVisible,
                action: TextInputAction.done,
                isDark: isDark,
                onSubmitted: (_) => onSubmit(),
                suffixIcon: GestureDetector(
                  onTap: () => context
                      .read<AuthBloc>()
                      .add(const PasswordVisibilityToggled()),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: AppTheme.textLowEmphasis,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 18),

            GestureDetector(
              onTap: () => onRememberChanged(!rememberMe),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  _ToggleBox(checked: rememberMe, isDark: isDark),
                  const SizedBox(width: 10),
                  Text('Keep me signed in',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 28),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => _SubmitButton(
                loading: state is AuthLoading,
                onTap: state is AuthLoading ? null : onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Text Field
// ─────────────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final String label;
  final String hint;
  final bool obscure;
  final bool isDark;
  final TextInputType keyboardType;
  final TextInputAction action;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.focus,
    required this.label,
    required this.hint,
    required this.isDark,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    required this.action,
    this.onSubmitted,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = widget.focus.hasFocus);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final labelColor = _focused
        ? (isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding)
        : (isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.ctrl,
          focusNode: widget.focus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.action,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextLow.withOpacity(0.6)
                  : AppTheme.textLowEmphasis.withOpacity(0.5),
            ),
            filled: true,
            fillColor: isDark
                ? (_focused ? AppTheme.darkSurface : AppTheme.darkSurface)
                : (_focused
                    ? AppTheme.primaryBranding.withOpacity(0.03)
                    : const Color(0xFFF7F8FA)),
            suffixIcon: widget.suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppTheme.primaryBranding, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppTheme.statusError, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppTheme.statusError, width: 1.6),
            ),
            errorStyle: GoogleFonts.inter(
                fontSize: 11, color: AppTheme.statusError),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Toggle Box
// ─────────────────────────────────────────
class _ToggleBox extends StatelessWidget {
  final bool checked;
  final bool isDark;
  const _ToggleBox({required this.checked, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? AppTheme.primaryBranding : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: checked
              ? AppTheme.primaryBranding
              : isDark
                  ? AppTheme.darkTextLow
                  : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
          : null,
    );
  }
}

// ─────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────
class _SubmitButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;
  const _SubmitButton({required this.loading, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.loading
                ? AppTheme.primaryBranding.withOpacity(0.55)
                : AppTheme.primaryBranding,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white60, strokeWidth: 2),
                )
              : Text('Sign in',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  )),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Restaurant Background
// ─────────────────────────────────────────
class _RestaurantBackground extends StatelessWidget {
  const _RestaurantBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Base gradient: warm slate → medium navy ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A6E8F),  // medium slate-blue
                  Color(0xFF35587A),  // medium navy
                  Color(0xFF243F5C),  // slightly deeper at bottom
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Warm amber top glow (candlelight) ──
          Positioned(
            top: -size.height * 0.05,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              height: size.height * 0.48,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x40F5A623),  // warm amber — stronger than before
                    Colors.transparent,
                  ],
                  radius: 0.72,
                ),
              ),
            ),
          ),

          // ── Soft white highlight top-left ──
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x18FFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Bokeh circles ──
          _BokehBlob(
            left: size.width * 0.76,
            top: size.height * 0.06,
            diameter: 120,
            color: const Color(0x1EF5A623),
          ),
          _BokehBlob(
            left: -20,
            top: size.height * 0.50,
            diameter: 160,
            color: const Color(0x163D7AB5),
          ),
          _BokehBlob(
            left: size.width * 0.52,
            top: size.height * 0.80,
            diameter: 100,
            color: const Color(0x18F5A623),
          ),

          // ── Subtle restaurant icons ──
          _BgIcon(
            icon: Icons.restaurant_rounded,
            left: size.width * 0.06,
            top: size.height * 0.07,
            size: 38,
            opacity: 0.13,
          ),
          _BgIcon(
            icon: Icons.wine_bar_rounded,
            left: size.width * 0.80,
            top: size.height * 0.18,
            size: 32,
            opacity: 0.11,
          ),
          _BgIcon(
            icon: Icons.dinner_dining_rounded,
            left: size.width * 0.10,
            top: size.height * 0.70,
            size: 34,
            opacity: 0.10,
          ),
          _BgIcon(
            icon: Icons.local_bar_rounded,
            left: size.width * 0.74,
            top: size.height * 0.65,
            size: 28,
            opacity: 0.10,
          ),
          _BgIcon(
            icon: Icons.star_rounded,
            left: size.width * 0.86,
            top: size.height * 0.46,
            size: 20,
            opacity: 0.14,
          ),
          _BgIcon(
            icon: Icons.restaurant_menu_rounded,
            left: size.width * 0.03,
            top: size.height * 0.38,
            size: 22,
            opacity: 0.10,
          ),
          _BgIcon(
            icon: Icons.stars_rounded,
            left: size.width * 0.60,
            top: size.height * 0.04,
            size: 18,
            opacity: 0.13,
          ),

          // ── Thin golden horizontal rule ──
          Positioned(
            top: size.height * 0.33,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.actionAccent.withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BokehBlob extends StatelessWidget {
  final double left;
  final double top;
  final double diameter;
  final Color color;
  const _BokehBlob({
    required this.left,
    required this.top,
    required this.diameter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _BgIcon extends StatelessWidget {
  final IconData icon;
  final double left;
  final double top;
  final double size;
  final double opacity;
  const _BgIcon({
    required this.icon,
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }
}
