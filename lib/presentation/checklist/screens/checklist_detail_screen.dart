import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/checklist_detail_entity.dart';
import '../bloc/checklist_detail_bloc.dart';

class ChecklistDetailScreen extends StatelessWidget {
  final int checklistAssignmentId;
  final int companyId;
  final String assignDate;
  final String checklistName;

  const ChecklistDetailScreen({
    super.key,
    required this.checklistAssignmentId,
    required this.companyId,
    required this.assignDate,
    required this.checklistName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChecklistDetailBloc>(
      create: (_) => sl<ChecklistDetailBloc>()
        ..add(LoadChecklistDetails(
          checklistAssignmentId: checklistAssignmentId,
          companyId: companyId,
          assignDate: assignDate,
        )),
      child: _ChecklistDetailView(checklistName: checklistName),
    );
  }
}

class _ChecklistDetailView extends StatelessWidget {
  final String checklistName;
  const _ChecklistDetailView({required this.checklistName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: BlocBuilder<ChecklistDetailBloc, ChecklistDetailState>(
        builder: (context, state) {
          if (state is ChecklistDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBranding,
                strokeWidth: 2.5,
              ),
            );
          }

          if (state is ChecklistDetailError) {
            return _ErrorView(message: state.message, isDark: isDark);
          }

          if (state is ChecklistDetailLoaded) {
            return _LoadedView(state: state, isDark: isDark);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? AppTheme.darkSurface : AppTheme.primaryBranding,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(checklistName,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          BlocBuilder<ChecklistDetailBloc, ChecklistDetailState>(
            builder: (_, state) {
              if (state is ChecklistDetailLoaded) {
                return Text(
                  '${state.summary.details.length} questions',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white70),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Loaded View
// ─────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final ChecklistDetailLoaded state;
  final bool isDark;
  const _LoadedView({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    return Column(
      children: [
        // Status header bar
        _StatusBar(summary: summary, isDark: isDark),
        // Progress bar
        _ProgressBar(details: summary.details, fieldValues: state.fieldValues, isDark: isDark),
        // Questions list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: summary.details.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _QuestionCard(
              index: i,
              detail: summary.details[i],
              currentValue: state.fieldValues[
                      summary.details[i].parentChecklistLabelId] ??
                  '',
              isReadOnly: summary.isSubmitted,
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Status Bar
// ─────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final ChecklistDetailSummary summary;
  final bool isDark;
  const _StatusBar({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final submitted = summary.isSubmitted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppTheme.darkSurface : AppTheme.surfaceWhite,
      child: Row(
        children: [
          Icon(
            submitted
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            size: 16,
            color: submitted
                ? AppTheme.statusSuccess
                : isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding,
          ),
          const SizedBox(width: 8),
          Text(
            submitted ? 'This checklist has been submitted' : 'Pending submission',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: submitted
                  ? AppTheme.statusSuccess
                  : isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (submitted ? AppTheme.statusSuccess : AppTheme.primaryBranding)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              submitted ? 'Submitted' : 'Pending',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: submitted
                    ? AppTheme.statusSuccess
                    : isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Progress Bar
// ─────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final List<ChecklistDetailEntity> details;
  final Map<int, String> fieldValues;
  final bool isDark;
  const _ProgressBar(
      {required this.details,
      required this.fieldValues,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final answered = details
        .where((d) =>
            (fieldValues[d.parentChecklistLabelId] ?? '').isNotEmpty)
        .length;
    final total = details.length;
    final progress = total > 0 ? answered / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF0F4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                ),
              ),
              Text(
                '$answered / $total answered',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor:
                  isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBranding),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Question Card — Dynamic Field Renderer
// ─────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final int index;
  final ChecklistDetailEntity detail;
  final String currentValue;
  final bool isReadOnly;
  final bool isDark;

  const _QuestionCard({
    required this.index,
    required this.detail,
    required this.currentValue,
    required this.isReadOnly,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final answered = currentValue.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: answered
              ? AppTheme.statusSuccess.withOpacity(isDark ? 0.25 : 0.2)
              : isDark
                  ? AppTheme.darkBorder
                  : const Color(0xFFE8ECF0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: answered
                        ? AppTheme.statusSuccess.withOpacity(0.12)
                        : AppTheme.primaryBranding.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: answered
                            ? AppTheme.statusSuccess
                            : AppTheme.primaryBranding,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.parentLabelName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextHigh
                              : AppTheme.textHighEmphasis,
                          height: 1.4,
                        ),
                      ),
                      if (detail.checklistDesc.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          detail.checklistDesc,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkTextLow
                                : AppTheme.textLowEmphasis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Field type chip
                _FieldTypeChip(type: detail.fieldType, isDark: isDark),
              ],
            ),
            const SizedBox(height: 14),
            // Dynamic input
            _buildField(context),
            // Note
            if (detail.checklistNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface
                      : AppTheme.scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded,
                        size: 13,
                        color: isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detail.checklistNote,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextLow
                              : AppTheme.textLowEmphasis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    switch (detail.fieldType) {
      case FieldType.radio:
        return _RadioField(
          options: detail.options,
          selected: currentValue,
          isReadOnly: isReadOnly,
          isDark: isDark,
          onChanged: (v) => context
              .read<ChecklistDetailBloc>()
              .add(UpdateFieldValue(
                  labelId: detail.parentChecklistLabelId, value: v)),
        );
      case FieldType.dropdown:
        return _DropdownField(
          options: detail.options,
          selected: currentValue,
          isReadOnly: isReadOnly,
          isDark: isDark,
          onChanged: (v) => context
              .read<ChecklistDetailBloc>()
              .add(UpdateFieldValue(
                  labelId: detail.parentChecklistLabelId, value: v)),
        );
      case FieldType.checkbox:
        return _CheckboxField(
          options: detail.options,
          selected: currentValue,
          isReadOnly: isReadOnly,
          isDark: isDark,
          onChanged: (v) => context
              .read<ChecklistDetailBloc>()
              .add(UpdateFieldValue(
                  labelId: detail.parentChecklistLabelId, value: v)),
        );
      case FieldType.textBox:
        return _TextBoxField(
          value: currentValue,
          isReadOnly: isReadOnly,
          isDark: isDark,
          onChanged: (v) => context
              .read<ChecklistDetailBloc>()
              .add(UpdateFieldValue(
                  labelId: detail.parentChecklistLabelId, value: v)),
        );
    }
  }
}

// ─────────────────────────────────────────
// Field Type Chip
// ─────────────────────────────────────────
class _FieldTypeChip extends StatelessWidget {
  final FieldType type;
  final bool isDark;
  const _FieldTypeChip({required this.type, required this.isDark});

  String get _label {
    switch (type) {
      case FieldType.radio:
        return 'Radio';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.checkbox:
        return 'Checkbox';
      case FieldType.textBox:
        return 'Text';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface
            : AppTheme.primaryBranding.withOpacity(0.06),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Radio Field
// ─────────────────────────────────────────
class _RadioField extends StatelessWidget {
  final List<String> options;
  final String selected;
  final bool isReadOnly;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _RadioField({
    required this.options,
    required this.selected,
    required this.isReadOnly,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: isReadOnly ? null : () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryBranding
                  : isDark
                      ? AppTheme.darkSurface
                      : AppTheme.scaffoldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryBranding
                    : isDark
                        ? AppTheme.darkBorder
                        : const Color(0xFFE4E7EC),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppTheme.darkTextLow
                              : const Color(0xFFCBD5E1),
                      width: isSelected ? 4 : 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  opt,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppTheme.darkTextHigh
                            : AppTheme.textHighEmphasis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────
// Dropdown Field
// ─────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final List<String> options;
  final String selected;
  final bool isReadOnly;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.options,
    required this.selected,
    required this.isReadOnly,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = options.contains(selected) ? selected : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Select an option',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
          ),
          dropdownColor:
              isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.inter(
            fontSize: 13,
            color:
                isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
          ),
          onChanged: isReadOnly
              ? null
              : (v) {
                  if (v != null) onChanged(v);
                },
          items: options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Checkbox Field
// ─────────────────────────────────────────
class _CheckboxField extends StatelessWidget {
  final List<String> options;
  final String selected;
  final bool isReadOnly;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _CheckboxField({
    required this.options,
    required this.selected,
    required this.isReadOnly,
    required this.isDark,
    required this.onChanged,
  });

  List<String> get _checkedItems =>
      selected.isEmpty ? [] : selected.split(',').map((e) => e.trim()).toList();

  @override
  Widget build(BuildContext context) {
    final checked = _checkedItems;
    return Column(
      children: options.map((opt) {
        final isChecked = checked.contains(opt);
        return GestureDetector(
          onTap: isReadOnly
              ? null
              : () {
                  final updated = List<String>.from(checked);
                  if (isChecked) {
                    updated.remove(opt);
                  } else {
                    updated.add(opt);
                  }
                  onChanged(updated.join(','));
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isChecked
                  ? AppTheme.primaryBranding.withOpacity(0.06)
                  : isDark
                      ? AppTheme.darkSurface
                      : AppTheme.scaffoldBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isChecked
                    ? AppTheme.primaryBranding.withOpacity(0.4)
                    : isDark
                        ? AppTheme.darkBorder
                        : const Color(0xFFE4E7EC),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppTheme.primaryBranding
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isChecked
                          ? AppTheme.primaryBranding
                          : isDark
                              ? AppTheme.darkTextLow
                              : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  opt,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isChecked ? FontWeight.w500 : FontWeight.w400,
                    color: isChecked
                        ? isDark
                            ? AppTheme.darkTextHigh
                            : AppTheme.textHighEmphasis
                        : isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────
// Text Box Field
// ─────────────────────────────────────────
class _TextBoxField extends StatefulWidget {
  final String value;
  final bool isReadOnly;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _TextBoxField({
    required this.value,
    required this.isReadOnly,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_TextBoxField> createState() => _TextBoxFieldState();
}

class _TextBoxFieldState extends State<_TextBoxField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      readOnly: widget.isReadOnly,
      maxLines: 3,
      minLines: 2,
      onChanged: widget.onChanged,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: widget.isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
      ),
      decoration: InputDecoration(
        hintText: 'Enter your response...',
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: widget.isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
        ),
        filled: true,
        fillColor: widget.isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: widget.isDark
                  ? AppTheme.darkBorder
                  : const Color(0xFFE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: widget.isDark
                  ? AppTheme.darkBorder
                  : const Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppTheme.primaryBranding, width: 1.6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Error View
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
            Icon(Icons.error_outline_rounded,
                size: 44,
                color: AppTheme.statusError.withOpacity(0.5)),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis,
                )),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBranding,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Go Back',
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
