import 'package:edupulse/app/data/models/exam_model.dart';
import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart' hide CustomTimeOfDay;
import 'package:uuid/uuid.dart';

class ExamService extends GetxService {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  final RxList<ExamModel> exams = <ExamModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchExams();
  }
  
 Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final fetchedExams = await _supabaseProvider.getExams();
      // Clear existing exams before adding new ones to prevent duplication
      exams.clear();
      exams.addAll(fetchedExams);
    } catch (e) {
      print('Error fetching exams: $e');
      // Consider showing an error message to the user
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<ExamModel?> getExamById(String id) async {
    try {
      // First check local cache
      final localExam = exams.firstWhereOrNull((exam) => exam.id == id);
      if (localExam != null) return localExam;
      
      // If not found locally, fetch from server
      return await _supabaseProvider.getExamById(id);
    } catch (e) {
      print('Error getting exam by ID: $e');
      return null;
    }
  }
  
  Future<bool> createExam(
    String title, 
    String? description, 
    DateTime examDate, 
    TimeOfDay examTime, 
    bool notificationsEnabled, 
    List<DateTime> reminderTimes, 
    List<String> tags, 
    {String? noteId}
  ) async {
    try {
      isLoading.value = true;
      
      final newExam = ExamModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser.value!.id,
        title: title,
        description: description,
        examDate: examDate,
        examTime: examTime,
        notificationsEnabled: notificationsEnabled,
        reminderTimes: reminderTimes,
        noteId: noteId,
        tags: tags,
      );
      
      final createdExam = await _supabaseProvider.createExam(newExam);
          // Check if exam with this ID already exists locally
      final existingIndex = exams.indexWhere((e) => e.id == createdExam.id);
      if (existingIndex != -1) {
        exams[existingIndex] = createdExam;
      } else {
        exams.add(createdExam);
      }
      
      // Schedule notifications if enabled
      if (notificationsEnabled) {
        _scheduleExamNotifications(createdExam);
      }
      
      return true;
    } catch (e) {
      print('Error creating exam: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateExam(ExamModel exam) async {
    try {
      isLoading.value = true;
      
      await _supabaseProvider.updateExam(exam);
      
      final index = exams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        exams[index] = exam;
        exams.refresh();
      }
      
      // Cancel old notifications and schedule new ones
      await _notificationService.cancelExamNotifications(exam.id);
      
      if (exam.notificationsEnabled) {
        _scheduleExamNotifications(exam);
      }
      
      return true;
    } catch (e) {
      print('Error updating exam: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteExam(String id) async {
    try {
      isLoading.value = true;
      await _supabaseProvider.deleteExam(id);
      
      // Cancel notifications
      await _notificationService.cancelExamNotifications(id);
      
      exams.removeWhere((exam) => exam.id == id);
      return true;
    } catch (e) {
      print('Error deleting exam: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  void _scheduleExamNotifications(ExamModel exam) {
    // Add notification for exam time
    _notificationService.scheduleExamNotification(
      exam.id,
      "Exam Reminder",
      "Your ${exam.title} exam starts in 30 minutes!",
      exam.fullExamDateTime.subtract(const Duration(minutes: 30)),
    );
    
    // Add notifications for reminder times
    for (int i = 0; i < exam.reminderTimes.length; i++) {
      final reminderTime = exam.reminderTimes[i];
      
      if (reminderTime.isAfter(DateTime.now())) {
        _notificationService.scheduleExamNotification(
          "${exam.id}_reminder_$i",
          "Exam Reminder",
          "Don't forget to study for your ${exam.title} exam!",
          reminderTime,
        );
      }
    }
    
    // Add day-before notification
    final dayBefore = exam.fullExamDateTime.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(DateTime.now())) {
      _notificationService.scheduleExamNotification(
        "${exam.id}_day_before",
        "Exam Tomorrow",
        "Your ${exam.title} exam is tomorrow at ${exam.formattedExamTime}!",
        dayBefore,
      );
    }
  }
  
  List<ExamModel> getUpcomingExams() {
    return exams.where((exam) => !exam.isPast).toList()
      ..sort((a, b) => a.fullExamDateTime.compareTo(b.fullExamDateTime));
  }
  
  List<ExamModel> getPastExams() {
    return exams.where((exam) => exam.isPast).toList()
      ..sort((a, b) => b.fullExamDateTime.compareTo(a.fullExamDateTime));
  }
}
