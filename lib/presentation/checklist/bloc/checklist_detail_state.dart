part of 'checklist_detail_bloc.dart';

class UploadError {
  final int labelId;
  final String message;
  const UploadError({required this.labelId, required this.message});
}

abstract class ChecklistDetailState extends Equatable {
  const ChecklistDetailState();
  @override
  List<Object?> get props => [];
}

class ChecklistDetailInitial extends ChecklistDetailState {
  const ChecklistDetailInitial();
}

class ChecklistDetailLoading extends ChecklistDetailState {
  const ChecklistDetailLoading();
}

class ChecklistDetailLoaded extends ChecklistDetailState {
  final ChecklistDetailSummary summary;
  final Map<int, String> fieldValues;
  final Map<int, String> noteValues;
  final Map<int, bool> flagValues;
  /// Stores CDN URLs returned by the upload API (ready for submission)
  final Map<int, List<String>> fileValues;
  /// Labels currently uploading a file
  final Set<int> uploadingLabels;
  /// Non-null when last upload failed; UI consumes via BlocListener
  final UploadError? uploadError;
  /// True while a save-draft or complete request is in flight
  final bool isSubmitting;
  /// Non-null on submit error; UI consumes via BlocListener
  final String? submitError;
  /// True after a successful submit; UI consumes via BlocListener
  final bool submitSuccess;

  const ChecklistDetailLoaded({
    required this.summary,
    required this.fieldValues,
    required this.noteValues,
    required this.flagValues,
    required this.fileValues,
    this.uploadingLabels = const {},
    this.uploadError,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });

  ChecklistDetailLoaded copyWith({
    ChecklistDetailSummary? summary,
    Map<int, String>? fieldValues,
    Map<int, String>? noteValues,
    Map<int, bool>? flagValues,
    Map<int, List<String>>? fileValues,
    Set<int>? uploadingLabels,
    UploadError? uploadError,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
  }) =>
      ChecklistDetailLoaded(
        summary: summary ?? this.summary,
        fieldValues: fieldValues ?? this.fieldValues,
        noteValues: noteValues ?? this.noteValues,
        flagValues: flagValues ?? this.flagValues,
        fileValues: fileValues ?? this.fileValues,
        uploadingLabels: uploadingLabels ?? this.uploadingLabels,
        uploadError: uploadError,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitError: submitError,
        submitSuccess: submitSuccess ?? this.submitSuccess,
      );

  bool isUploading(int labelId) => uploadingLabels.contains(labelId);

  @override
  List<Object?> get props => [
        summary,
        fieldValues,
        noteValues,
        flagValues,
        fileValues,
        uploadingLabels,
        uploadError,
        isSubmitting,
        submitError,
        submitSuccess,
      ];
}

class ChecklistDetailError extends ChecklistDetailState {
  final String message;
  const ChecklistDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
