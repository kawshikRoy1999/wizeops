import 'package:equatable/equatable.dart';

class ChecklistDetailEntity extends Equatable {
  final int parentChecklistLabelId;
  final int parentChecklistId;
  final String parentLabelName;
  final String checklistDesc;
  final String checklistValue;
  final String optionText;
  final String customFieldTypeName;
  final String checklistStatus;
  final String checklistNote;
  final int checkListAssignmentValuesId;
  final bool flagRaised;
  final String filePathsJson;
  /// Raw HTML string from the API, e.g. "<p>step 1</p><p>step 2</p>" or ""
  final String storeActionsteps;

  const ChecklistDetailEntity({
    required this.parentChecklistLabelId,
    required this.parentChecklistId,
    required this.parentLabelName,
    required this.checklistDesc,
    required this.checklistValue,
    required this.optionText,
    required this.customFieldTypeName,
    required this.checklistStatus,
    required this.checklistNote,
    required this.checkListAssignmentValuesId,
    required this.flagRaised,
    required this.filePathsJson,
    this.storeActionsteps = '',
  });

  List<String> get options => optionText.isNotEmpty
      ? optionText.split(',').map((e) => e.trim()).toList()
      : [];

  /// Parses HTML action steps into plain text lines.
  /// "<p>step 1</p><p>step 2</p>" → ["step 1", "step 2"]
  /// "<u>some text</u>" → ["some text"]  (any tag structure)
  List<String> get actionSteps {
    if (storeActionsteps.isEmpty) return [];

    final stripTags = RegExp(r'<[^>]+>');

    String _clean(String s) => s
        .replaceAll(stripTags, '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    // Try <p> tags first — common when content comes from a rich-text editor
    final pTag = RegExp(
      r'<p[^>]*>(.*?)<\/p>',
      caseSensitive: false,
      dotAll: true,
    );
    final fromP = pTag
        .allMatches(storeActionsteps)
        .map((m) => _clean(m.group(1) ?? ''))
        .where((s) => s.isNotEmpty)
        .toList();

    if (fromP.isNotEmpty) return fromP;

    // Fallback: strip all tags and return the whole text as one item
    final plain = _clean(storeActionsteps);
    return plain.isEmpty ? [] : [plain];
  }

  FieldType get fieldType {
    switch (customFieldTypeName.toLowerCase()) {
      case 'radio button':
        return FieldType.radio;
      case 'dropdown':
        return FieldType.dropdown;
      case 'checkbox':
        return FieldType.checkbox;
      default:
        return FieldType.textBox;
    }
  }

  @override
  List<Object?> get props => [parentChecklistLabelId, checklistValue, flagRaised, filePathsJson];
}

enum FieldType { radio, dropdown, checkbox, textBox }

class ChecklistDetailSummary extends Equatable {
  final String checklistName;
  final String checklistStatus;
  final int checklistAssignmentId;
  final List<ChecklistDetailEntity> details;

  const ChecklistDetailSummary({
    required this.checklistName,
    required this.checklistStatus,
    required this.checklistAssignmentId,
    required this.details,
  });

  bool get isSubmitted {
    final s = checklistStatus.toLowerCase();
    return s == 'completed' || s == 'submit' || s == 'submitted';
  }

  @override
  List<Object?> get props => [checklistAssignmentId];
}
