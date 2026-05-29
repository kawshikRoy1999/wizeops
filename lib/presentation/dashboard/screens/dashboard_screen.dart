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

class _DashboardView extends StatefulWidget {
  final UserEntity user;
  const _DashboardView({required this.user});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  bool _isCardView = false;
  String? _filterStatus; // null = All

  void _toggleView() => setState(() => _isCardView = !_isCardView);

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
              _GreetingHeader(user: widget.user, isDark: isDark),
              _DatePickerBar(
                user: widget.user,
                isDark: isDark,
                isCardView: _isCardView,
                onToggleView: _toggleView,
                filterStatus: _filterStatus,
                onFilterChanged: (v) => setState(() => _filterStatus = v),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v.abs() > 350) _toggleView();
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) {
                      final offset = child.key == ValueKey(_isCardView)
                          ? const Offset(1, 0)
                          : const Offset(-1, 0);
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: offset,
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _ChecklistBody(
                      key: ValueKey('${_isCardView}_$_filterStatus'),
                      user: widget.user,
                      isDark: isDark,
                      isCardView: _isCardView,
                      filterStatus: _filterStatus,
                    ),
                  ),
                ),
              ),
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
                  child: SettingsScreen(user: widget.user),
                ),
              ),
            ),
            child: _AvatarChip(user: widget.user),
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
  final bool isCardView;
  final VoidCallback onToggleView;
  final String? filterStatus;
  final ValueChanged<String?> onFilterChanged;
  const _DatePickerBar({
    required this.user,
    required this.isDark,
    required this.isCardView,
    required this.onToggleView,
    required this.filterStatus,
    required this.onFilterChanged,
  });

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
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBg : AppTheme.scaffoldBg,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBranding
                          .withOpacity(isDark ? 0.25 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBranding
                            .withOpacity(isDark ? 0.4 : 0.2),
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
                        const SizedBox(width: 3),
                        Icon(Icons.expand_more_rounded,
                            size: 14,
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

                // ── Filter dropdown ──
                _FilterDropdown(
                  isDark: isDark,
                  value: filterStatus,
                  onChanged: onFilterChanged,
                ),
                const SizedBox(width: 8),

                // ── View toggle ──
                GestureDetector(
                  onTap: onToggleView,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isCardView
                          ? AppTheme.primaryBranding
                              .withOpacity(isDark ? 0.35 : 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCardView
                            ? AppTheme.primaryBranding
                                .withOpacity(isDark ? 0.5 : 0.3)
                            : (isDark
                                ? AppTheme.darkBorder
                                : const Color(0xFFDDE1E7)),
                      ),
                    ),
                    child: Icon(
                      isCardView
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      size: 16,
                      color: isCardView
                          ? (isDark
                              ? const Color(0xFF6B9FE4)
                              : AppTheme.primaryBranding)
                          : (isDark
                              ? AppTheme.darkTextLow
                              : AppTheme.textLowEmphasis),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ── Refresh ──
                GestureDetector(
                  onTap: () =>
                      context.read<ChecklistBloc>().add(FetchChecklists(
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
  final bool isCardView;
  final String? filterStatus;
  const _ChecklistBody({
    super.key,
    required this.user,
    required this.isDark,
    required this.isCardView,
    required this.filterStatus,
  });

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
          // Apply status filter
          final items = filterStatus == null
              ? state.items
              : state.items.where((item) {
                  final s = item.checklistStatus.toLowerCase().trim();
                  switch (filterStatus) {
                    case 'submitted':
                      return s == 'completed' ||
                          s == 'submit' ||
                          s == 'submitted';
                    case 'draft':
                      return s == 'save';
                    case 'pending':
                      return s != 'completed' &&
                          s != 'submit' &&
                          s != 'submitted' &&
                          s != 'save';
                    default:
                      return true;
                  }
                }).toList();

          if (items.isEmpty) {
            return _EmptyView(isDark: isDark, isFiltered: filterStatus != null);
          }

          if (isCardView) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _ChecklistGridCard(
                item: items[i],
                user: user,
                selectedDate: state.selectedDate,
                isDark: isDark,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ChecklistCard(
              item: items[i],
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
// Checklist Grid Card (card view)
// ─────────────────────────────────────────
class _ChecklistGridCard extends StatelessWidget {
  final dynamic item;
  final UserEntity user;
  final DateTime selectedDate;
  final bool isDark;
  const _ChecklistGridCard({
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
    final filled = item.totalFilledCount as int;
    final total = item.totalCount as int;
    final ratio = item.progressRatio as double;

    // Accent color consistent with list view
    final Color accent = submitted
        ? AppTheme.statusSuccess
        : isDark
            ? const Color(0xFF6B9FE4)
            : AppTheme.primaryBranding;

    // Track color for the thin progress bar
    final Color trackColor = isDark
        ? (submitted ? const Color(0xFF1E3A2A) : const Color(0xFF1E2540))
        : (submitted ? const Color(0xFFBFE8D0) : const Color(0xFFDDE5F8));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: submitted
              ? AppTheme.statusSuccess.withOpacity(isDark ? 0.35 : 0.3)
              : isDark
                  ? AppTheme.darkBorder
                  : const Color(0xFFE8ECF0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: status badge + chevron ──
                Row(
                  children: [
                    _StatusBadge(checklistStatus: item.checklistStatus as String),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: isDark
                          ? AppTheme.darkTextLow
                          : AppTheme.textLowEmphasis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Checklist name ──
                Expanded(
                  child: Text(
                    item.checklistName as String,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextHigh
                          : AppTheme.textHighEmphasis,
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Thin progress bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: submitted ? 1.0 : (total == 0 ? 0.0 : ratio),
                      backgroundColor: trackColor,
                      color: accent,
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Count + date ──
                Row(
                  children: [
                    // count chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.15 : 0.09),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            submitted
                                ? Icons.check_circle_outline_rounded
                                : Icons.checklist_rounded,
                            size: 11,
                            color: accent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            total == 0 ? '—' : '$filled/$total',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // date
                    Text(
                      item.assignDateTime as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis,
                      ),
                    ),
                  ],
                ),
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

  static const double size = 44;

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

    final double stroke = size >= 60 ? 4.5 : 3;
    final double innerSize = size * 0.77;
    final double iconSize = size >= 60 ? 22 : 16;
    final double hintIconSize = size >= 60 ? 20 : 14;
    final double textSize = size >= 60
        ? (total >= 10 ? 13 : 15)
        : (total >= 10 ? 9 : 10);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track ring (full circle background)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: stroke,
              color: trackColor,
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: submitted ? 1.0 : ratio,
              strokeWidth: stroke,
              color: activeColor,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Inner circle + fraction / check
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: innerFill,
              shape: BoxShape.circle,
            ),
            child: submitted
                ? Icon(Icons.check_rounded, size: iconSize, color: activeColor)
                : Center(
                    child: total == 0
                        ? Icon(Icons.hourglass_empty_rounded,
                            size: hintIconSize, color: activeColor)
                        : Text(
                            '$filled/$total',
                            style: GoogleFonts.inter(
                              fontSize: textSize,
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
// Filter Dropdown
// ─────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final bool isDark;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  static const _options = <String?, String>{
    null: 'All',
    'pending': 'Pending',
    'draft': 'Draft',
    'submitted': 'Submitted',
  };

  static const _icons = <String?, IconData>{
    null: Icons.tune_rounded,
    'pending': Icons.hourglass_empty_rounded,
    'draft': Icons.edit_note_rounded,
    'submitted': Icons.check_circle_outline_rounded,
  };

  static const _colors = <String?, Color>{
    null: AppTheme.primaryBranding,
    'pending': Color(0xFF6B9FE4),
    'draft': Color(0xFFB45309),
    'submitted': AppTheme.statusSuccess,
  };

  static const _darkColors = <String?, Color>{
    null: Color(0xFF9BB3CB),
    'pending': Color(0xFF6B9FE4),
    'draft': Color(0xFFFFCA28),
    'submitted': AppTheme.statusSuccess,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;
    final Color dotColor = isDark ? _darkColors[value]! : _colors[value]!;
    final Color iconColor = isActive
        ? dotColor
        : (isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis);
    final Color bg = isActive
        ? dotColor.withOpacity(isDark ? 0.18 : 0.10)
        : Colors.transparent;
    final Color border = isActive
        ? dotColor.withOpacity(isDark ? 0.45 : 0.28)
        : (isDark ? AppTheme.darkBorder : const Color(0xFFDDE1E7));

    return PopupMenuButton<String?>(
      onSelected: (v) => onChanged(v == '__all__' ? null : v),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: 4,
      offset: const Offset(0, 36),
      itemBuilder: (_) => _options.entries.map((e) {
        final optKey = e.key;
        final optLabel = e.value;
        final optIcon = _icons[optKey]!;
        final optColor = isDark ? _darkColors[optKey]! : _colors[optKey]!;
        final selected = value == optKey;
        return PopupMenuItem<String?>(
          value: optKey ?? '__all__',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(optIcon,
                  size: 15,
                  color: selected
                      ? optColor
                      : (isDark
                          ? AppTheme.darkTextLow
                          : AppTheme.textLowEmphasis)),
              const SizedBox(width: 10),
              Text(
                optLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? optColor
                      : (isDark
                          ? AppTheme.darkTextHigh
                          : AppTheme.textHighEmphasis),
                ),
              ),
              if (selected) ...[
                const Spacer(),
                Icon(Icons.check_rounded, size: 14, color: optColor),
              ],
            ],
          ),
        );
      }).toList(),
      // ── Compact icon button — fixed 30×30, never overflows ──
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Icon(Icons.tune_rounded, size: 16, color: iconColor),
          ),
          // Active dot indicator
          if (isActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.darkBg : AppTheme.scaffoldBg,
                    width: 1.5,
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
  final bool isFiltered;
  const _EmptyView({required this.isDark, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered
                ? Icons.filter_list_off_rounded
                : Icons.checklist_rounded,
            size: 48,
            color: isDark
                ? AppTheme.darkTextLow.withOpacity(0.4)
                : AppTheme.textLowEmphasis.withOpacity(0.35),
          ),
          const SizedBox(height: 14),
          Text(
            isFiltered
                ? 'No checklists match this filter'
                : 'No checklists for this date',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isFiltered
                ? 'Try a different filter or date'
                : 'Try selecting a different date',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: (isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis)
                  .withOpacity(0.7),
            ),
          ),
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
