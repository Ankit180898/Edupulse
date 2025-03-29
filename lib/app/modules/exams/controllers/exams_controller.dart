import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edupulse/app/data/services/exam_service.dart';
import 'package:edupulse/app/data/services/note_service.dart';
import 'package:edupulse/app/data/models/exam_model.dart' hide TimeOfDay;
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ExamsController extends GetxController {
  final ExamService _examService = Get.find<ExamService>();
  final NoteService _noteService = Get.find<NoteService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().add(const Duration(days: 7)).obs;
  final Rx<TimeOfDay> selectedTime = const TimeOfDay(hour: 10, minute: 0).obs;
  final RxBool notificationsEnabled = true.obs;
  final RxList<DateTime> reminderTimes = <DateTime>[].obs;
  final RxString selectedNoteId = ''.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString currentExamId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExams();
    loadNotes();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.onClose();
  }

  void resetFields() {
    titleController.clear();
    descriptionController.clear();
    tagController.clear();
    selectedDate.value = DateTime.now().add(const Duration(days: 7));
    selectedTime.value = const TimeOfDay(hour: 10, minute: 0);
    notificationsEnabled.value = true;
    reminderTimes.clear();
    selectedNoteId.value = '';
    selectedTags.clear();
    currentExamId.value = '';
  }

  Future<void> fetchExams() async {
    await _examService.fetchExams();
  }

  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      await _noteService.fetchNotes();
      notes.value = _noteService.notes;
    } catch (e) {
      print('Error loading notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ExamModel> get upcomingExams => _examService.getUpcomingExams();

  List<ExamModel> get pastExams => _examService.getPastExams();

  List<ExamModel> get exams {
    if (searchQuery.isEmpty) {
      return _examService.exams;
    } else {
      return _examService.exams.where((exam) {
        return exam.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               (exam.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
               exam.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void addReminder(DateTime time) {
    if (!reminderTimes.contains(time)) {
      reminderTimes.add(time);
    }
  }

  void removeReminder(DateTime time) {
    reminderTimes.remove(time);
  }

  void addReminderDaysBeforeExam(int days) {
    final examDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    final reminderTime = examDateTime.subtract(Duration(days: days));

    // Check if a similar reminder already exists
    bool alreadyExists = false;
    for (final existing in reminderTimes) {
      final diff = existing.difference(reminderTime).inHours.abs();
      if (diff < 24) {
        alreadyExists = true;
        break;
      }
    }

    if (!alreadyExists) {
      reminderTimes.add(reminderTime);
      reminderTimes.sort((a, b) => a.compareTo(b));
    }
  }

  void selectNote(String noteId) {
    selectedNoteId.value = noteId;

    // If a note is selected, load its tags
    if (noteId.isNotEmpty) {
      final selectedNote = notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => NoteModel(
          id: '',
          userId: '',
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tags: [],
        ),
      );

      if (selectedNote.id.isNotEmpty) {
        selectedTags.value = [...selectedNote.tags];
      }
    }
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

  NoteModel? getSelectedNote() {
    if (selectedNoteId.isEmpty) return null;

    try {
      return notes.firstWhere((note) => note.id == selectedNoteId.value);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadExamData(String examId) async {
    try {
      isLoading.value = true;

      final exam = await _examService.getExamById(examId);
      if (exam != null) {
        currentExamId.value = exam.id;
        titleController.text = exam.title;
        descriptionController.text = exam.description ?? '';
        selectedDate.value = exam.examDate;
        selectedTime.value = exam.examTime;
        notificationsEnabled.value = exam.notificationsEnabled;
        reminderTimes.value = [...exam.reminderTimes];
        selectedNoteId.value = exam.noteId ?? '';
        selectedTags.value = [...exam.tags];
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error loading exam: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveExam() async {
    if (titleController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Title is required');
      return;
    }

    try {
      isLoading.value = true;

      bool success;
      if (currentExamId.value.isEmpty) {
        // Create new exam
        success = await _examService.createExam(
          titleController.text,
          descriptionController.text.isEmpty ? null : descriptionController.text,
          selectedDate.value,
          selectedTime.value,
          notificationsEnabled.value,
          reminderTimes,
          selectedTags,
          noteId: selectedNoteId.value.isEmpty ? null : selectedNoteId.value,
        );
      } else {
        // Update existing exam
        final exam = await _examService.getExamById(currentExamId.value);
        if (exam != null) {
          final updatedExam = exam.copyWith(
            title: titleController.text,
            description: descriptionController.text.isEmpty ? null : descriptionController.text,
            examDate: selectedDate.value,
            examTime: selectedTime.value,
            notificationsEnabled: notificationsEnabled.value,
            reminderTimes: reminderTimes,
            noteId: selectedNoteId.value.isEmpty ? null : selectedNoteId.value,
            tags: selectedTags,
          );

          success = await _examService.updateExam(updatedExam);
        } else {
          throw Exception('Exam not found');
        }
      }

      if (success) {
        Get.back();
        showSuccessSnackbar(
          'Success',
          currentExamId.value.isEmpty ? 'Exam created successfully' : 'Exam updated successfully',
        );
        resetFields();
      } else {
        showErrorSnackbar(
          'Error',
          currentExamId.value.isEmpty ? 'Failed to create exam' : 'Failed to update exam',
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error saving exam: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExam(String examId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this exam? This action cannot be undone.'),
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

        final success = await _examService.deleteExam(examId);

        if (success) {
          if (Get.currentRoute.contains('/exam-add')) {
            Get.back(); // Go back to exams list if we're on add/edit page
          }
          showSuccessSnackbar('Success', 'Exam deleted successfully');
        } else {
          showErrorSnackbar('Error', 'Failed to delete exam');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error deleting exam: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  String getFormattedTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  String getRemainingDays(ExamModel exam) {
    final daysLeft = exam.daysUntilExam;

    if (daysLeft == 0) {
      return 'Today';
    } else if (daysLeft == 1) {
      return 'Tomorrow';
    } else {
      return '$daysLeft days left';
    }
  }

  Color getTimelineColor(ExamModel exam) {
    final daysLeft = exam.daysUntilExam;

    if (daysLeft < 0) {
      return Colors.grey; // Past exam
    } else if (daysLeft <= 2) {
      return Colors.red; // Very soon
    } else if (daysLeft <= 7) {
      return Colors.orange; // Coming up
    } else {
      return Colors.green; // Plenty of time
    }
  }

  String getFormattedReminderTime(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now).inDays;

    if (difference < 0) {
      return 'Past reminder';
    } else if (difference == 0) {
      return 'Today at ${DateFormat('h:mm a').format(reminderTime)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${DateFormat('h:mm a').format(reminderTime)}';
    } else {
      return '${DateFormat('MMM d').format(reminderTime)} at ${DateFormat('h:mm a').format(reminderTime)}';
    }
  }
  void addExam(ExamModel exam) {
    exams.add(exam);
    update();
  }
}