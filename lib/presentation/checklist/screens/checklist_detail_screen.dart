import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/checklist_detail_entity.dart';
import '../bloc/checklist_detail_bloc.dart';

class ChecklistDetailScreen extends StatelessWidget {
  final int checklistAssignmentId;
  final int companyId;
  final String assignDate;
  final String checklistName;
  /// True when checklistStatus == "Completed" — always read-only
  final bool isSubmitted;
  /// True when the selected date is today — only today + not Completed is editable
  final bool isToday;

  const ChecklistDetailScreen({
    super.key,
    required this.checklistAssignmentId,
    required this.companyId,
    required this.assignDate,
    required this.checklistName,
    this.isSubmitted = false,
    this.isToday = true,
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
      child: _ChecklistDetailView(
        checklistName: checklistName,
        companyId: companyId,
        isSubmittedHint: isSubmitted,
        isToday: isToday,
      ),
    );
  }
}

class _ChecklistDetailView extends StatelessWidget {
  final String checklistName;
  final int companyId;
  final bool isSubmittedHint;
  final bool isToday;
  const _ChecklistDetailView({
    required this.checklistName,
    required this.companyId,
    required this.isSubmittedHint,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<ChecklistDetailBloc, ChecklistDetailState>(
        listenWhen: (prev, curr) =>
            curr is ChecklistDetailLoaded &&
            (curr.uploadError != null ||
                curr.submitError != null ||
                curr.submitSuccess),
        listener: (context, state) {
          if (state is! ChecklistDetailLoaded) return;

          if (state.uploadError != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Upload failed: ${state.uploadError!.message}',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
              backgroundColor: AppTheme.statusError,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          }

          if (state.submitError != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.submitError!,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
              backgroundColor: AppTheme.statusError,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          }

          if (state.submitSuccess) {
            Navigator.pop(context, true); // true = refresh dashboard
          }
        },
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
            return _LoadedView(
              state: state,
              isDark: isDark,
              isSubmittedHint: isSubmittedHint,
              isToday: isToday,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    // Completed → green, past date (not today) → grey-tinted, otherwise brand
    final isReadOnly = isSubmittedHint || !isToday;
    final Color appBarColor = isSubmittedHint
        ? AppTheme.statusSuccess
        : !isToday
            ? (isDark ? AppTheme.darkSurface : const Color(0xFF6B7280))
            : isDark
                ? AppTheme.darkSurface
                : AppTheme.primaryBranding;

    return AppBar(
      backgroundColor: appBarColor,
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
      actions: isReadOnly
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('Read Only',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ]
          : null,
    );
  }
}

// ─────────────────────────────────────────
// Loaded View
// ─────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final ChecklistDetailLoaded state;
  final bool isDark;
  final bool isSubmittedHint;
  final bool isToday;
  const _LoadedView({
    required this.state,
    required this.isDark,
    required this.isSubmittedHint,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    // Read-only when: API says Completed OR hint already set OR not today's date
    final isCompleted = summary.isSubmitted || isSubmittedHint;
    final isReadOnly = isCompleted || !isToday;
    return Column(
      children: [
        // Read-only banner
        if (isReadOnly)
          _ReadOnlyBanner(isCompleted: isCompleted, isDark: isDark),
        // Status header bar
        _StatusBar(summary: summary, isDark: isDark),
        // Progress bar
        _ProgressBar(details: summary.details, fieldValues: state.fieldValues, isDark: isDark),
        // Questions list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 16, 16, isReadOnly ? 24 : 16),
            itemCount: summary.details.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final id = summary.details[i].parentChecklistLabelId;
              return _QuestionCard(
                index: i,
                detail: summary.details[i],
                currentValue: state.fieldValues[id] ?? '',
                currentNote: state.noteValues[id] ?? '',
                isFlagged: state.flagValues[id] ?? false,
                filePaths: state.fileValues[id] ?? [],
                isReadOnly: isReadOnly,
                isDark: isDark,
              );
            },
          ),
        ),
        // Action buttons — hidden in read-only mode
        if (!isReadOnly)
          _SubmitBar(submittingStatus: state.submittingStatus, isDark: isDark),
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
    final s = summary.checklistStatus.toLowerCase().trim();

    final Color color;
    final IconData icon;
    final String message;
    final String badge;

    if (s == 'completed' || s == 'submit') {
      color = AppTheme.statusSuccess;
      icon = Icons.check_circle_rounded;
      message = 'This checklist has been completed';
      badge = 'Completed';
    } else if (s == 'save') {
      color = const Color(0xFFB45309);
      icon = Icons.save_rounded;
      message = 'This checklist is saved as draft';
      badge = 'Draft';
    } else {
      color = isDark ? AppTheme.darkTextHigh : AppTheme.primaryBranding;
      icon = Icons.pending_actions_rounded;
      message = 'Pending submission';
      badge = 'Pending';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppTheme.darkSurface : AppTheme.surfaceWhite,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
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
        color: isReadOnly
            ? (isDark ? const Color(0xFF1C1F26) : const Color(0xFFF7F9FC))
            : (isDark ? AppTheme.darkCard : AppTheme.surfaceWhite),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReadOnly
              ? (isDark ? const Color(0xFF2E3340) : const Color(0xFFDDE3EC))
              : answered
                  ? (isDark ? const Color(0xFF2E6B45) : const Color(0xFFB2DFCB))
                  : isDark
                      ? AppTheme.darkBorder
                      : const Color(0xFFE8ECF0),
        ),
        boxShadow: isDark || isReadOnly
            ? []
            : [
                BoxShadow(
                  color: const Color(0x08000000),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isReadOnly
            ? _buildReadOnlyContent(context)
            : _buildEditableContent(context, answered),
      ),
    );
  }

  // ── Read-only layout: clean data display, no form controls ──
  Widget _buildReadOnlyContent(BuildContext context) {
    final hasNote = currentNote.isNotEmpty;
    final hasFiles = filePaths.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2D36)
                    : const Color(0xFFE8ECF4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.darkTextHigh
                        : AppTheme.textHighEmphasis,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.darkTextHigh
                          : AppTheme.textHighEmphasis,
                      height: 1.4,
                    ),
                  ),
                  if (detail.checklistDesc.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail.checklistDesc,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Answer value display
        _ReadOnlyAnswerDisplay(
          value: currentValue,
          fieldType: detail.fieldType,
          isDark: isDark,
        ),
        // Note — only if non-empty
        if (hasNote) ...[
          const SizedBox(height: 10),
          _ReadOnlyNote(note: currentNote, isDark: isDark),
        ],
        // Flag — only if raised
        if (isFlagged) ...[
          const SizedBox(height: 8),
          _FlagChip(isDark: isDark),
        ],
        // Files
        if (hasFiles) ...[
          const SizedBox(height: 10),
          _AttachmentList(
            labelId: detail.parentChecklistLabelId,
            filePaths: filePaths,
            isReadOnly: true,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  // ── Editable layout: full form controls ──
  Widget _buildEditableContent(BuildContext context, bool answered) {
    return Column(
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
            _FieldTypeChip(type: detail.fieldType, isDark: isDark),
          ],
        ),
        const SizedBox(height: 14),
        _buildField(context),
        const SizedBox(height: 14),
        _Divider(isDark: isDark),
        const SizedBox(height: 12),
        _NoteField(
          labelId: detail.parentChecklistLabelId,
          value: currentNote,
          isReadOnly: false,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RaiseFlagCheckbox(
                labelId: detail.parentChecklistLabelId,
                isFlagged: isFlagged,
                isReadOnly: false,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            BlocBuilder<ChecklistDetailBloc, ChecklistDetailState>(
              buildWhen: (p, c) =>
                  c is ChecklistDetailLoaded &&
                  p is ChecklistDetailLoaded &&
                  p.isUploading(detail.parentChecklistLabelId) !=
                      c.isUploading(detail.parentChecklistLabelId),
              builder: (context, state) {
                final uploading = state is ChecklistDetailLoaded &&
                    state.isUploading(detail.parentChecklistLabelId);
                return _AttachmentButton(
                  labelId: detail.parentChecklistLabelId,
                  filePaths: filePaths,
                  isReadOnly: false,
                  isUploading: uploading,
                  isDark: isDark,
                );
              },
            ),
          ],
        ),
        if (filePaths.isNotEmpty) ...[
          const SizedBox(height: 10),
          _AttachmentList(
            labelId: detail.parentChecklistLabelId,
            filePaths: filePaths,
            isReadOnly: false,
            isDark: isDark,
          ),
        ],
      ],
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

/// Strips the internal code suffix from option values.
/// e.g. "Done#87_chk_1" → "Done",  "Yes#12_chk_2" → "Yes"
String _optionLabel(String raw) {
  final idx = raw.indexOf('#');
  return idx > 0 ? raw.substring(0, idx).trim() : raw.trim();
}

// ─────────────────────────────────────────
// Read-Only Answer Display
// ─────────────────────────────────────────
class _ReadOnlyAnswerDisplay extends StatelessWidget {
  final String value;
  final FieldType fieldType;
  final bool isDark;

  const _ReadOnlyAnswerDisplay({
    required this.value,
    required this.fieldType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232730) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF333848) : const Color(0xFFDDE3EC),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.remove_rounded,
                size: 14,
                color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis),
            const SizedBox(width: 6),
            Text(
              'No answer recorded',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
              ),
            ),
          ],
        ),
      );
    }

    if (fieldType == FieldType.textBox) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232730) : const Color(0xFFEEF2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF333848) : const Color(0xFFCDD5E0),
          ),
        ),
        child: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
            height: 1.55,
          ),
        ),
      );
    }

    // Radio, Dropdown, Checkbox — render as filled chips
    final items = fieldType == FieldType.checkbox
        ? value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [value];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((item) {
        final label = _optionLabel(item);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A3329) : const Color(0xFFE4F4EB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2E6B45) : const Color(0xFF8DC9A2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded,
                  size: 13,
                  color: isDark
                      ? const Color(0xFF6DCE97)
                      : const Color(0xFF1E7A3F)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF6DCE97)
                      : const Color(0xFF1E7A3F),
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
// Read-Only Note
// ─────────────────────────────────────────
class _ReadOnlyNote extends StatelessWidget {
  final String note;
  final bool isDark;

  const _ReadOnlyNote({required this.note, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 13,
              color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
            ),
            const SizedBox(width: 4),
            Text(
              'Remarks / Notes',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF0F4FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF2C3445) : const Color(0xFFCDD5E6),
            ),
          ),
          child: Text(
            note,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextHigh : AppTheme.textHighEmphasis,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Flag Chip (read-only indicator)
// ─────────────────────────────────────────
class _FlagChip extends StatelessWidget {
  final bool isDark;
  const _FlagChip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF7A2828) : const Color(0xFFEFA8A8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded,
              size: 13,
              color: isDark ? const Color(0xFFFF8080) : const Color(0xFFD93030)),
          const SizedBox(width: 5),
          Text(
            'Flag Raised',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFF8080) : const Color(0xFFD93030),
            ),
          ),
        ],
      ),
    );
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
                  _optionLabel(opt),
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
                    child: Text(_optionLabel(opt)),
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
                  _optionLabel(opt),
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
// Read-Only Banner
// ─────────────────────────────────────────
class _ReadOnlyBanner extends StatelessWidget {
  final bool isCompleted;
  final bool isDark;
  const _ReadOnlyBanner({required this.isCompleted, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppTheme.statusSuccess : const Color(0xFF6B7280);
    final icon = isCompleted ? Icons.check_circle_rounded : Icons.history_rounded;
    final message = isCompleted
        ? 'This checklist has been completed and is view-only.'
        : 'Only today\'s checklists can be edited. This is view-only.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withOpacity(isDark ? 0.15 : 0.08),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
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
                // Simple toggle: checked → true, unchecked → false
                UpdateFlagValue(labelId: labelId, raised: !isFlagged),
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
  final bool isUploading;
  final bool isDark;

  const _AttachmentButton({
    required this.labelId,
    required this.filePaths,
    required this.isReadOnly,
    required this.isUploading,
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
        isDark: isDark,
        blocContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = filePaths.length;
    final canTap = !isReadOnly && !isUploading;
    return GestureDetector(
      onTap: canTap ? () => _showPicker(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isUploading
              ? AppTheme.primaryBranding.withOpacity(0.06)
              : isDark
                  ? AppTheme.darkSurface
                  : AppTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUploading
                ? AppTheme.primaryBranding.withOpacity(0.3)
                : isDark
                    ? AppTheme.darkBorder
                    : const Color(0xFFE4E7EC),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppTheme.primaryBranding,
                ),
              )
            else
              Icon(
                Icons.attach_file_rounded,
                size: 15,
                color: isDark ? AppTheme.darkTextLow : AppTheme.textLowEmphasis,
              ),
            const SizedBox(width: 5),
            Text(
              isUploading
                  ? 'Uploading…'
                  : count > 0
                      ? '$count file${count > 1 ? 's' : ''}'
                      : 'Attach',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: count > 0 || isUploading
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isUploading || count > 0
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
  final bool isDark;
  final BuildContext blocContext;

  const _AttachmentSheet({
    required this.labelId,
    required this.isDark,
    required this.blocContext,
  });

  void _dispatch(BuildContext ctx, String filePath, {String? fileName}) {
    blocContext.read<ChecklistDetailBloc>().add(
          UploadFile(labelId: labelId, filePath: filePath, fileName: fileName),
        );
    Navigator.pop(ctx);
  }

  Future<void> _openCamera(BuildContext ctx) async {
    final picker = ImagePicker();
    final photo =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null && ctx.mounted) {
      // Generate a readable timestamped name — camera temp paths are meaningless
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_$ts.jpg';
      _dispatch(ctx, photo.path, fileName: fileName);
    }
  }

  Future<void> _browseFiles(BuildContext ctx) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null && ctx.mounted) {
      final file = result.files.single;
      if (file.path != null) {
        // Use the original filename from the picker (already meaningful)
        _dispatch(ctx, file.path!, fileName: file.name);
      }
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
  final bool isReadOnly;
  final bool isDark;

  const _AttachmentList({
    required this.labelId,
    required this.filePaths,
    required this.isReadOnly,
    required this.isDark,
  });

  static bool _isImage(String path) {
    final ext = path.split('?').first.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'heic', 'webp', 'gif'].contains(ext);
  }

  String _fileName(String path) =>
      Uri.decodeFull(path.split('?').first.split('/').last.split('\\').last);

  void _open(BuildContext context, String path) {
    if (_isImage(path)) {
      final imageUrls = filePaths.where(_isImage).toList();
      final index = imageUrls.indexOf(path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageGalleryViewer(
            urls: imageUrls,
            initialIndex: index,
          ),
        ),
      );
    } else {
      launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: filePaths.map((path) {
        final name = _fileName(path);
        final isImage = _isImage(path);
        return GestureDetector(
          onTap: () => _open(context, path),
          child: Container(
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
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      path,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_rounded,
                        size: 36,
                        color: AppTheme.primaryBranding,
                      ),
                    ),
                  )
                else
                  Icon(
                    _fileIcon(name),
                    size: 36,
                    color: AppTheme.primaryBranding,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextHigh
                              : AppTheme.textHighEmphasis,
                        ),
                      ),
                      Text(
                        isImage ? 'Tap to view' : 'Tap to open',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isDark
                              ? AppTheme.darkTextLow
                              : AppTheme.textLowEmphasis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isReadOnly)
                  GestureDetector(
                    onTap: () {
                      final updated =
                          filePaths.where((p) => p != path).toList();
                      context.read<ChecklistDetailBloc>().add(
                            UpdateFileValue(labelId: labelId, paths: updated),
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: isDark
                            ? AppTheme.darkTextLow
                            : AppTheme.textLowEmphasis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'mp4':
      case 'mov':
        return Icons.videocam_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

// ─────────────────────────────────────────
// Full-screen image gallery viewer
// ─────────────────────────────────────────
class _ImageGalleryViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _ImageGalleryViewer(
      {required this.urls, required this.initialIndex});

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.urls.length}',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
            onPressed: () => launchUrl(
              Uri.parse(widget.urls[_current]),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.urls.length,
        pageController: PageController(initialPage: widget.initialIndex),
        onPageChanged: (i) => setState(() => _current = i),
        builder: (_, i) => PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.urls[i]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image_rounded,
                color: Colors.white54, size: 48),
          ),
        ),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(
              color: AppTheme.primaryBranding, strokeWidth: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Submit Bar (Draft + Complete buttons)
// ─────────────────────────────────────────
class _SubmitBar extends StatelessWidget {
  final String? submittingStatus;
  final bool isDark;
  const _SubmitBar({required this.submittingStatus, required this.isDark});

  void _submit(BuildContext context, String status) {
    context.read<ChecklistDetailBloc>().add(SubmitChecklist(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF0F4),
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
      ),
      // SafeArea pushes content above the on-screen nav bar (back/home/recents)
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
        children: [
          // Draft button
          Expanded(
            child: _SubmitButton(
              label: 'Save Draft',
              icon: Icons.save_outlined,
              isLoading: submittingStatus == 'Save',
              isDisabled: submittingStatus != null,
              filled: false,
              isDark: isDark,
              onTap: () => _submit(context, 'Save'),
            ),
          ),
          const SizedBox(width: 12),
          // Complete button
          Expanded(
            child: _SubmitButton(
              label: 'Complete',
              icon: Icons.check_circle_outline_rounded,
              isLoading: submittingStatus == 'Completed',
              isDisabled: submittingStatus != null,
              filled: true,
              isDark: isDark,
              onTap: () => _submit(context, 'Completed'),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isDisabled;
  final bool filled;
  final bool isDark;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isDisabled,
    required this.filled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = filled ? Colors.white : AppTheme.primaryBranding;
    final Color bg = filled
        ? (isDisabled && !isLoading
            ? AppTheme.statusSuccess.withOpacity(0.4)
            : AppTheme.statusSuccess)
        : (isDark ? AppTheme.darkCard : AppTheme.primaryBranding.withOpacity(0.06));

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: filled
              ? null
              : Border.all(
                  color: AppTheme.primaryBranding.withOpacity(
                      isDisabled && !isLoading ? 0.1 : (isDark ? 0.3 : 0.2)),
                ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16,
                        color: isDisabled ? fg.withOpacity(0.4) : fg),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? fg.withOpacity(0.4) : fg,
                      ),
                    ),
                  ],
                ),
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
