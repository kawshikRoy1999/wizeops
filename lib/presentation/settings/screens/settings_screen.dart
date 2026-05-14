import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final UserEntity user;
  const SettingsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark
                    ? AppTheme.darkTextHigh
                    : AppTheme.textHighEmphasis),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
            ),
          ),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Profile Card ──
            _ProfileCard(user: user, isDark: isDark),
            const SizedBox(height: 24),

            // ── Account Info ──
            _SectionLabel('Account', isDark: isDark),
            const SizedBox(height: 10),
            _InfoGroup(isDark: isDark, items: [
              _InfoRow(
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: user.userEmail,
                isDark: isDark,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: '${user.userPhoneCode} ${user.phone}',
                isDark: isDark,
              ),
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Username',
                value: user.userName,
                isDark: isDark,
              ),
              _InfoRow(
                icon: Icons.shield_outlined,
                label: 'Role',
                value: user.roles,
                isDark: isDark,
                isLast: true,
              ),
            ]),
            const SizedBox(height: 24),

            // ── Preferences ──
            _SectionLabel('Preferences', isDark: isDark),
            const SizedBox(height: 10),
            _InfoGroup(isDark: isDark, items: [
              _ThemeToggleRow(isDark: isDark),
            ]),
            const SizedBox(height: 24),

            // ── Session ──
            _SectionLabel('Session', isDark: isDark),
            const SizedBox(height: 10),
            _SignOutButton(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _ProfileCard({required this.user, required this.isDark});

  String get _initials {
    final f = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final l = user.lastName.isNotEmpty ? user.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryBranding,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _initials,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextHigh
                        : AppTheme.textHighEmphasis,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.userEmail,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextLow
                        : AppTheme.textLowEmphasis,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Pill(
                      label: user.roles,
                      bg: AppTheme.primaryBranding.withOpacity(0.1),
                      fg: AppTheme.primaryBranding,
                    ),
                    const SizedBox(width: 6),
                    _Pill(
                      label: user.isActive ? 'Active' : 'Inactive',
                      bg: (user.isActive
                              ? AppTheme.statusSuccess
                              : AppTheme.statusError)
                          .withOpacity(0.12),
                      fg: user.isActive
                          ? AppTheme.statusSuccess
                          : AppTheme.statusError,
                      dot: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final bool dot;
  const _Pill(
      {required this.label,
      required this.bg,
      required this.fg,
      this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
                width: 5,
                height: 5,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: fg)),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
      ),
    );
  }
}

// ─────────────────────────────────────────
// Info Group Container
// ─────────────────────────────────────────
class _InfoGroup extends StatelessWidget {
  final List<Widget> items;
  final bool isDark;
  const _InfoGroup({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
        ),
      ),
      child: Column(children: items),
    );
  }
}

// ─────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 17,
                  color: isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.darkTextHigh
                      : AppTheme.textHighEmphasis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 45,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF0F4),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Theme Toggle Row
// ─────────────────────────────────────────
class _ThemeToggleRow extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            size: 17,
            color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
          ),
          const SizedBox(width: 12),
          Text(
            'Dark Mode',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
          ),
          const Spacer(),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final on = mode == ThemeMode.dark;
              return GestureDetector(
                onTap: () => context.read<ThemeCubit>().toggle(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 44,
                  height: 26,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: on
                        ? AppTheme.primaryBranding
                        : const Color(0xFFD1D9E0),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    alignment:
                        on ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sign Out Button
// ─────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final bool isDark;
  const _SignOutButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _confirmSignOut(context),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded,
                    size: 17, color: AppTheme.statusError),
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.statusError,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkTextLow
                        : AppTheme.textLowEmphasis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCard
            : AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text(
          'You will be returned to the login screen.',
          style: GoogleFonts.inter(
              fontSize: 13, color: AppTheme.textLowEmphasis),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppTheme.textLowEmphasis,
                    fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text('Sign Out',
                style: GoogleFonts.inter(
                    color: AppTheme.statusError,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
