import 'dart:io';

import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/note_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotesController extends GetxController {
  final NoteService _noteService = Get.find<NoteService>();
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  final RxList<String> selectedTags = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSummarizing = false.obs;
  final RxBool isExtractingKeyPoints = false.obs; // New dedicated flag for key points
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString selectedFileName = ''.obs;
  final RxString currentNoteId = ''.obs;
  final RxString summary = ''.obs;
  final RxList<String> keyPoints = <String>[].obs;
  final RxBool showKeyPoints = false.obs;
  final RxInt _remainingQueries = 0.obs; // Make it reactive

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
    _updateRemainingQueries(); // Initialize remaining queries
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    super.onClose();
  }

  // Update remaining queries from auth service
  void _updateRemainingQueries() {
    _remainingQueries.value = _authService.remainingQueries;
  }

  void resetFields() {
    titleController.clear();
    contentController.clear();
    tagController.clear();
    selectedTags.clear();
    selectedFile.value = null;
    selectedFileName.value = '';
    currentNoteId.value = '';
    summary.value = '';
    keyPoints.clear();
    showKeyPoints.value = false;
  }

  Future<void> fetchNotes() async {
    await _noteService.fetchNotes();
  }

  List<NoteModel> get notes {
    if (searchQuery.isEmpty) {
      return _noteService.notes;
    } else {
      return _noteService.notes.where((note) {
        return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
            note.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !selectedTags.contains(tag)) {
      selectedTags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    selectedTags.remove(tag);
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        selectedFile.value = File(result.files.single.path!);
        selectedFileName.value = result.files.single.name;
      }
    } catch (e) {
      showErrorSnackbar('File Selection Error', 'Error selecting file: ${e.toString()}');
    }
  }

  Future<void> removeFile() async {
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  Future<void> loadNoteData(String noteId) async {
    try {
      isLoading.value = true;
      currentNoteId.value = noteId;

      final note = await _noteService.getNoteById(noteId);
      if (note != null) {
        print("Loaded Note: ${note.toJson()}"); // Debugging

        titleController.text = note.title;
        contentController.text = note.content;

        // Properly handle tags
        selectedTags.clear();
        if (note.tags.isNotEmpty) {
          selectedTags.addAll(List<String>.from(note.tags));
        }

        // Handle summary if exists
        if (note.summary != null && note.summary!.isNotEmpty) {
          summary.value = note.summary!;
        }

        // Trigger UI update
        update();
      } else {
        print("Note is null!");
        showErrorSnackbar('Error', 'Note not found');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error loading note: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveNote() async {
    if (titleController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Title is required');
      return;
    }

    if (contentController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Content is required');
      return;
    }

    try {
      isLoading.value = true;

      bool success;
      if (currentNoteId.value.isEmpty) {
        // Create new note
        success = await _noteService.createNote(
          titleController.text,
          contentController.text,
          selectedTags,
          file: selectedFile.value,
        );
      } else {
        // Update existing note
        final note = await _noteService.getNoteById(currentNoteId.value);
        if (note != null) {
          final updatedNote = note.copyWith(
            title: titleController.text,
            content: contentController.text,
            tags: selectedTags,
            updatedAt: DateTime.now(),
          );

          success = await _noteService.updateNote(updatedNote);
        } else {
          throw Exception('Note not found');
        }
      }

      if (success) {
        Get.back();
        showSuccessSnackbar(
          'Success',
          currentNoteId.value.isEmpty ? 'Note created successfully' : 'Note updated successfully',
        );
        resetFields();
      } else {
        showErrorSnackbar(
          'Error',
          currentNoteId.value.isEmpty ? 'Failed to create note' : 'Failed to update note',
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error saving note: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;

        final success = await _noteService.deleteNote(noteId);

        if (success) {
          if (Get.currentRoute.contains('/note-detail')) {
            Get.back(); // Go back to notes list if we're on detail page
          }
          showSuccessSnackbar('Success', 'Note deleted successfully');
        } else {
          showErrorSnackbar('Error', 'Failed to delete note');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error deleting note: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateSummary(String noteId) async {
    try {
      // Check if user has reached query limit
      if (!_authService.canUseAIFeatures) {
        showUpgradeDialog();
        return;
      }

      isSummarizing.value = true;

      final generatedSummary = await _noteService.generateSummary(noteId);

      if (generatedSummary != null) {
        summary.value = generatedSummary;
        _updateRemainingQueries(); // Update remaining queries after successful operation
        Get.toNamed('/summary', arguments: {'noteId': noteId});
        showSuccessSnackbar('Success', 'Summary generated successfully');
      } else {
        if (_authService.canUseAIFeatures) {
          showErrorSnackbar('Error', 'Failed to generate summary');
        } else {
          showUpgradeDialog();
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error generating summary: ${e.toString()}');
    } finally {
      isSummarizing.value = false;
    }
  }

  Future<void> extractKeyPoints(String noteId) async {
    try {
      // Check if user has reached query limit
      if (!_authService.canUseAIFeatures) {
        showUpgradeDialog();
        return;
      }

      isExtractingKeyPoints.value = true; // Use dedicated flag
      showKeyPoints.value = true;

      final extractedPoints = await _noteService.extractKeyPoints(noteId);

      if (extractedPoints.isNotEmpty) {
        keyPoints.value = extractedPoints;
        _updateRemainingQueries(); // Update remaining queries after successful operation
      } else {
        if (_authService.canUseAIFeatures) {
          showErrorSnackbar('Error', 'Failed to extract key points');
        } else {
          showUpgradeDialog();
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error extracting key points: ${e.toString()}');
    } finally {
      isExtractingKeyPoints.value = false; // Reset the dedicated flag
    }
  }

  void showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Upgrade Required'),
        content: const Text(
          'You\'ve reached your daily free usage limit for AI features. '
          'Upgrade to a premium plan for unlimited AI summaries, MCQs, and more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/subscription');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  // Make remaining queries a reactive getter
  RxInt get remainingQueries => _remainingQueries;

  bool get canUseAIFeatures => _authService.canUseAIFeatures;
}
