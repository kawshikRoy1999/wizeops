import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/screens/login_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../checklist/screens/checklist_detail_screen.dart';
import '../bloc/checklist_bloc.dart';

class DashboardScreen extends StatelessWidget {
  final UserEntity user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChecklistBloc>(
      create: (_) {
        final bloc = sl<ChecklistBloc>();
        final now = DateTime.now();
        bloc.add(FetchChecklists(
          assignDateTime: _formatDate(now),
          companyId: user.companyId,
          userId: user.id,
          selectedDate: now,
        ));
        return bloc;
      },
      child: _DashboardView(user: user),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String formatDateStatic(DateTime d) => _formatDate(d);
}

class _DashboardView extends StatelessWidget {
  final UserEntity user;
  const _DashboardView({required this.user});

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
        appBar: _buildAppBar(context, isDark),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _GreetingHeader(user: user, isDark: isDark),
              _DatePickerBar(user: user, isDark: isDark),
              Expanded(child: _ChecklistBody(user: user, isDark: isDark)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? AppTheme.darkSurface : AppTheme.primaryBranding,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'WizeOps',
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: SettingsScreen(user: user),
                ),
              ),
            ),
            child: _AvatarChip(user: user),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// AppBar Avatar
// ─────────────────────────────────────────
class _AvatarChip extends StatelessWidget {
  final UserEntity user;
  const _AvatarChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            .toUpperCase();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _GreetingHeader({required this.user, required this.isDark});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      color: isDark ? AppTheme.darkSurface : AppTheme.primaryBranding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 2),
          Text(user.fullName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Date Picker Bar
// ─────────────────────────────────────────
class _DatePickerBar extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _DatePickerBar({required this.user, required this.isDark});

  String _label(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = DateTime(d.year, d.month, d.day);
    if (picked == today) return 'Today';
    if (picked == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (picked == today.add(const Duration(days: 1))) return 'Tomorrow';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _navigateDay(BuildContext context, DateTime current, int offset) {
    final firstDate = DateTime(2020);
    final lastDate  = DateTime(2030, 12, 31);
    final next = DateTime(current.year, current.month, current.day + offset);
    if (next.isBefore(firstDate) || next.isAfter(lastDate)) return;
    context.read<ChecklistBloc>().add(FetchChecklists(
          assignDateTime: _formatDate(next),
          companyId: user.companyId,
          userId: user.id,
          selectedDate: next,
        ));
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) {
        final dark = Theme.of(ctx).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: dark
                ? const ColorScheme.dark(
                    primary: AppTheme.primaryBranding,
                    onPrimary: Colors.white,
                    surface: AppTheme.darkCard,
                    onSurface: AppTheme.darkTextHigh,
                    secondaryContainer: AppTheme.primaryBranding,
                    onSecondaryContainer: Colors.white,
                    outline: AppTheme.darkBorder,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryBranding,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppTheme.textHighEmphasis,
                    secondaryContainer: AppTheme.primaryBranding,
                    onSecondaryContainer: Colors.white,
                    outline: Color(0xFFE4E7EC),
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                // primaryBranding (#2C3E50) is near-black — invisible on dark dialog.
                foregroundColor: dark
                    ? const Color(0xFF6B9FE4) // light blue, matches dark-mode arc colour
                    : AppTheme.primaryBranding,
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor:
                  dark ? AppTheme.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<ChecklistBloc>().add(FetchChecklists(
            assignDateTime: _formatDate(picked),
            companyId: user.companyId,
            userId: user.id,
            selectedDate: picked,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistBloc, ChecklistState>(
      builder: (context, state) {
        final date = state.selectedDate;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBg : AppTheme.scaffoldBg,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 15,
                  color: isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis),
              const SizedBox(width: 8),
              Text(
                'Checklists for',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                ),
              ),
              const SizedBox(width: 6),
              // ── Previous day ──
              _DayNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _navigateDay(context, date, -1),
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              // ── Date pill (tap to open calendar) ──
              GestureDetector(
                onTap: () => _pickDate(context, date),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBranding.withOpacity(
                        isDark ? 0.25 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBranding.withOpacity(
                          isDark ? 0.4 : 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _label(date),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextHigh
                              : AppTheme.primaryBranding,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more_rounded,
                          size: 15,
                          color: isDark
                              ? AppTheme.darkTextHigh
                              : AppTheme.primaryBranding),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // ── Next day ──
              _DayNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _navigateDay(context, date, 1),
                isDark: isDark,
              ),
              const Spacer(),
              // Refresh
              GestureDetector(
                onTap: () => context.read<ChecklistBloc>().add(FetchChecklists(
                      assignDateTime: _formatDate(date),
                      companyId: user.companyId,
                      userId: user.id,
                      selectedDate: date,
                    )),
                child: Icon(Icons.refresh_rounded,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkTextLow
                        : AppTheme.textLowEmphasis),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Checklist Body
// ─────────────────────────────────────────
class _ChecklistBody extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  const _ChecklistBody({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistBloc, ChecklistState>(
      builder: (context, state) {
        if (state is ChecklistLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryBranding,
              strokeWidth: 2.5,
            ),
          );
        }

        if (state is ChecklistError) {
          return _ErrorView(message: state.message, isDark: isDark);
        }

        if (state is ChecklistLoaded) {
          if (state.items.isEmpty) {
            return _EmptyView(isDark: isDark);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ChecklistCard(
              item: state.items[i],
              user: user,
              selectedDate: state.selectedDate,
              isDark: isDark,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────
// Checklist Card
// ─────────────────────────────────────────
class _ChecklistCard extends StatelessWidget {
  final dynamic item;
  final UserEntity user;
  final DateTime selectedDate;
  final bool isDark;
  const _ChecklistCard({
    required this.item,
    required this.user,
    required this.selectedDate,
    required this.isDark,
  });

  static bool _isTodayDate(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final submitted = item.isSubmitted as bool;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: submitted
              ? AppTheme.statusSuccess.withOpacity(isDark ? 0.3 : 0.25)
              : isDark
                  ? AppTheme.darkBorder
                  : const Color(0xFFE8ECF0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChecklistDetailScreen(
                checklistAssignmentId: item.checklistAssignmentId as int,
                companyId: user.companyId,
                assignDate: DashboardScreen._formatDate(selectedDate),
                checklistName: item.checklistName as String,
                isSubmitted: item.isSubmitted as bool,
                isToday: _isTodayDate(selectedDate),
              ),
            ),
          ).then((refresh) {
            if (refresh == true && context.mounted) {
              context.read<ChecklistBloc>().add(FetchChecklists(
                    assignDateTime: DashboardScreen._formatDate(selectedDate),
                    companyId: user.companyId,
                    userId: user.id,
                    selectedDate: selectedDate,
                  ));
            }
          }),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Progress indicator
                _ProgressCircle(item: item, isDark: isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.checklistName as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextHigh
                              : AppTheme.textHighEmphasis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.assignDateTime as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextLow
                              : AppTheme.textLowEmphasis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusBadge(checklistStatus: item.checklistStatus as String),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Progress Circle (left indicator on card)
// ─────────────────────────────────────────
class _ProgressCircle extends StatelessWidget {
  final dynamic item;
  final bool isDark;
  const _ProgressCircle({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final submitted = item.isSubmitted as bool;
    final filled = item.totalFilledCount as int;
    final total = item.totalCount as int;
    final ratio = item.progressRatio as double;

    // primaryBranding (#2C3E50) is near-black — invisible on dark inner fills.
    // Use a brighter blue in dark mode so the arc and fraction text are legible.
    final activeColor = submitted
        ? AppTheme.statusSuccess
        : isDark
            ? const Color(0xFF6B9FE4)   // light blue — visible on #161C35
            : AppTheme.primaryBranding; // dark navy — visible on #EEF2FF

    // Solid dark-mode colors — no opacity stacking on dark backgrounds
    final Color trackColor;
    final Color innerFill;
    if (isDark) {
      trackColor = submitted
          ? const Color(0xFF1E3A2A)   // dark green ring track
          : const Color(0xFF1E2540);  // dark blue ring track
      innerFill = submitted
          ? const Color(0xFF172820)   // dark green inner
          : const Color(0xFF161C35);  // dark blue inner
    } else {
      trackColor = submitted
          ? const Color(0xFFBFE8D0)   // light green track
          : const Color(0xFFCDD8F8);  // light blue track
      innerFill = submitted
          ? const Color(0xFFE6F4EB)   // light green inner
          : const Color(0xFFEEF2FF);  // light blue inner
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track ring (full circle background)
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3,
              color: trackColor,
            ),
          ),
          // Progress arc
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: submitted ? 1.0 : ratio,
              strokeWidth: 3,
              color: activeColor,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Inner circle + fraction / check
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: innerFill,
              shape: BoxShape.circle,
            ),
            child: submitted
                ? Icon(Icons.check_rounded, size: 16, color: activeColor)
                : Center(
                    child: total == 0
                        ? Icon(Icons.hourglass_empty_rounded,
                            size: 14, color: activeColor)
                        : Text(
                            '$filled/$total',
                            style: GoogleFonts.inter(
                              fontSize: total >= 10 ? 9 : 10,
                              fontWeight: FontWeight.w700,
                              color: activeColor,
                              height: 1,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String checklistStatus;
  const _StatusBadge({required this.checklistStatus});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = checklistStatus.toLowerCase().trim();

    final Color fg;
    final Color bg;
    final Color border;
    final String label;

    if (s == 'completed' || s == 'submit' || s == 'submitted') {
      fg = AppTheme.statusSuccess;
      bg = isDark ? const Color(0xFF1A3028) : AppTheme.statusSuccess.withOpacity(0.12);
      border = isDark ? const Color(0xFF2A5040) : AppTheme.statusSuccess.withOpacity(0.3);
      label = 'Submitted';
    } else if (s == 'save') {
      fg = isDark ? const Color(0xFFFFCA28) : const Color(0xFFB45309);
      bg = isDark ? const Color(0xFF2D2200) : const Color(0xFFFEF3C7);
      border = isDark ? const Color(0xFF4D3A00) : const Color(0xFFFCD34D);
      label = 'Draft';
    } else {
      fg = isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding;
      bg = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF0F4FF);
      border = isDark
          ? const Color(0xFF2A3D5C)
          : AppTheme.primaryBranding.withOpacity(0.15);
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Day Navigation Button (prev / next)
// ─────────────────────────────────────────
class _DayNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _DayNavButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.primaryBranding.withOpacity(isDark ? 0.2 : 0.07),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: AppTheme.primaryBranding.withOpacity(isDark ? 0.35 : 0.18),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rounded,
              size: 48,
              color: isDark
                  ? AppTheme.darkTextLow.withOpacity(0.4)
                  : AppTheme.textLowEmphasis.withOpacity(0.35)),
          const SizedBox(height: 14),
          Text('No checklists for this date',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
              )),
          const SizedBox(height: 4),
          Text('Try selecting a different date',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: (isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis)
                    .withOpacity(0.7),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Error State
// ─────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 44,
                color: AppTheme.statusError.withOpacity(0.5)),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                )),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.read<ChecklistBloc>().add(
                    FetchChecklists(
                      assignDateTime:
                          '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      companyId: 0,
                      userId: '',
                      selectedDate: DateTime.now(),
                    ),
                  ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBranding,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Retry',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
