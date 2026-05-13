import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
            itemBuilder: (context, i) {
              final id = summary.details[i].parentChecklistLabelId;
              return _QuestionCard(
                index: i,
                detail: summary.details[i],
                currentValue: state.fieldValues[id] ?? '',
                currentNote: state.noteValues[id] ?? '',
                isFlagged: !(state.flagValues[id] ?? true),
                filePaths: state.fileValues[id] ?? [],
                isReadOnly: summary.isSubmitted,
                isDark: isDark,
              );
            },
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
                  color: answered > 0
                      ? AppTheme.statusSuccess
                      : isDark
                          ? AppTheme.darkTextHigh
                          : AppTheme.textHighEmphasis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppTheme.darkBorder : const Color(0xFFE8ECF0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.statusSuccess),
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
  final String currentNote;
  final bool isFlagged;
  final List<String> filePaths;
  final bool isReadOnly;
  final bool isDark;

  const _QuestionCard({
    required this.index,
    required this.detail,
    required this.currentValue,
    required this.currentNote,
    required this.isFlagged,
    required this.filePaths,
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
            const SizedBox(height: 14),
            _Divider(isDark: isDark),
            const SizedBox(height: 12),
            // Remarks / Notes textarea
            _NoteField(
              labelId: detail.parentChecklistLabelId,
              value: currentNote,
              isReadOnly: isReadOnly,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            // Raise a Flag + Attachments row
            Row(
              children: [
                Expanded(
                  child: _RaiseFlagCheckbox(
                    labelId: detail.parentChecklistLabelId,
                    isFlagged: isFlagged,
                    isReadOnly: isReadOnly,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                _AttachmentButton(
                  labelId: detail.parentChecklistLabelId,
                  filePaths: filePaths,
                  isReadOnly: isReadOnly,
                  isDark: isDark,
                ),
              ],
            ),
            if (filePaths.isNotEmpty) ...[
              const SizedBox(height: 10),
              _AttachmentList(
                labelId: detail.parentChecklistLabelId,
                filePaths: filePaths,
                isDark: isDark,
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
// Divider
// ─────────────────────────────────────────
class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF0F4),
    );
  }
}

// ─────────────────────────────────────────
// Note Field (Remarks / Notes textarea)
// ─────────────────────────────────────────
class _NoteField extends StatefulWidget {
  final int labelId;
  final String value;
  final bool isReadOnly;
  final bool isDark;

  const _NoteField({
    required this.labelId,
    required this.value,
    required this.isReadOnly,
    required this.isDark,
  });

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 14,
              color: widget.isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
            const SizedBox(width: 5),
            Text(
              'Remarks / Notes',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _ctrl,
          readOnly: widget.isReadOnly,
          maxLines: 3,
          minLines: 2,
          onChanged: (v) => context
              .read<ChecklistDetailBloc>()
              .add(UpdateNoteValue(labelId: widget.labelId, value: v)),
          style: GoogleFonts.inter(
            fontSize: 13,
            color: widget.isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
          ),
          decoration: InputDecoration(
            hintText: 'Add your remarks or notes here...',
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: widget.isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
            filled: true,
            fillColor: widget.isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: widget.isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: widget.isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryBranding, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Raise a Flag Checkbox
// ─────────────────────────────────────────
class _RaiseFlagCheckbox extends StatelessWidget {
  final int labelId;
  final bool isFlagged;
  final bool isReadOnly;
  final bool isDark;

  const _RaiseFlagCheckbox({
    required this.labelId,
    required this.isFlagged,
    required this.isReadOnly,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReadOnly
          ? null
          : () => context.read<ChecklistDetailBloc>().add(
                // visual isFlagged is inverted from API status:
                // checking (isFlagged goes false→true) sends status=false
                // unchecking (isFlagged goes true→false) sends status=true
                UpdateFlagValue(labelId: labelId, raised: isFlagged),
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isFlagged
              ? AppTheme.statusError.withOpacity(0.08)
              : isDark
                  ? AppTheme.darkSurface
                  : AppTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFlagged
                ? AppTheme.statusError.withOpacity(0.4)
                : isDark
                    ? AppTheme.darkBorder
                    : const Color(0xFFE4E7EC),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isFlagged ? AppTheme.statusError : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isFlagged
                      ? AppTheme.statusError
                      : isDark
                          ? AppTheme.darkTextLow
                          : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isFlagged
                  ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.flag_rounded,
              size: 13,
              color: isFlagged
                  ? AppTheme.statusError
                  : isDark
                      ? AppTheme.darkTextLow
                      : AppTheme.textLowEmphasis,
            ),
            const SizedBox(width: 4),
            Text(
              'Raise a Flag',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isFlagged ? FontWeight.w600 : FontWeight.w400,
                color: isFlagged
                    ? AppTheme.statusError
                    : isDark
                        ? AppTheme.darkTextLow
                        : AppTheme.textLowEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Attachment Button
// ─────────────────────────────────────────
class _AttachmentButton extends StatelessWidget {
  final int labelId;
  final List<String> filePaths;
  final bool isReadOnly;
  final bool isDark;

  const _AttachmentButton({
    required this.labelId,
    required this.filePaths,
    required this.isReadOnly,
    required this.isDark,
  });

  Future<void> _showPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AttachmentSheet(
        labelId: labelId,
        existingPaths: filePaths,
        isDark: isDark,
        blocContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = filePaths.length;
    return GestureDetector(
      onTap: isReadOnly ? null : () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 15,
              color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
            const SizedBox(width: 5),
            Text(
              count > 0 ? '$count file${count > 1 ? 's' : ''}' : 'Attach',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.w400,
                color: count > 0
                    ? AppTheme.primaryBranding
                    : isDark
                        ? AppTheme.darkTextLow
                        : AppTheme.textLowEmphasis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Attachment Bottom Sheet
// ─────────────────────────────────────────
class _AttachmentSheet extends StatelessWidget {
  final int labelId;
  final List<String> existingPaths;
  final bool isDark;
  final BuildContext blocContext;

  const _AttachmentSheet({
    required this.labelId,
    required this.existingPaths,
    required this.isDark,
    required this.blocContext,
  });

  void _addPath(BuildContext ctx, String path) {
    final updated = [...existingPaths, path];
    blocContext
        .read<ChecklistDetailBloc>()
        .add(UpdateFileValue(labelId: labelId, paths: updated));
    Navigator.pop(ctx);
  }

  Future<void> _openCamera(BuildContext ctx) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null && ctx.mounted) _addPath(ctx, photo.path);
  }

  Future<void> _browseFiles(BuildContext ctx) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null && ctx.mounted) {
      _addPath(ctx, result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis;
    final subColor = isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFDDE1E7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Attachment',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            Text(
              'Choose how you want to attach a file',
              style: GoogleFonts.inter(fontSize: 12, color: subColor),
            ),
            const SizedBox(height: 20),
            _SheetOption(
              icon: Icons.camera_alt_rounded,
              label: 'Open Camera',
              subtitle: 'Take a photo or video',
              isDark: isDark,
              onTap: () => _openCamera(context),
            ),
            const SizedBox(height: 10),
            _SheetOption(
              icon: Icons.folder_open_rounded,
              label: 'Browse Files',
              subtitle: 'Pick from device storage',
              isDark: isDark,
              onTap: () => _browseFiles(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBranding.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.primaryBranding),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Attachment List (selected files)
// ─────────────────────────────────────────
class _AttachmentList extends StatelessWidget {
  final int labelId;
  final List<String> filePaths;
  final bool isDark;

  const _AttachmentList({
    required this.labelId,
    required this.filePaths,
    required this.isDark,
  });

  String _fileName(String path) => path.split('/').last.split('\\').last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: filePaths.map((path) {
        final name = _fileName(path);
        final isImage = ['.jpg', '.jpeg', '.png', '.heic', '.webp']
            .any((ext) => name.toLowerCase().endsWith(ext));
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : const Color(0xFFE4E7EC),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
                size: 16,
                color: AppTheme.primaryBranding,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final updated = filePaths.where((p) => p != path).toList();
                  context.read<ChecklistDetailBloc>().add(
                        UpdateFileValue(labelId: labelId, paths: updated),
                      );
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
