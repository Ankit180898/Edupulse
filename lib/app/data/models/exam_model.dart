import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime examDate;
  final TimeOfDay examTime;
  final bool notificationsEnabled;
  final List<DateTime> reminderTimes;
  final String? noteId;
  final List<String> tags;

  ExamModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.examDate,
    required this.examTime,
    this.notificationsEnabled = true,
    required this.reminderTimes,
    this.noteId,
    required this.tags,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> parseReminderTimes(List<dynamic> reminderList) {
      return reminderList.map((time) => DateTime.parse(time)).toList();
    }

    return ExamModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      examDate: DateTime.parse(json['exam_date']),
      examTime: TimeOfDay(
        hour: json['exam_hour'] ?? 0,
        minute: json['exam_minute'] ?? 0,
      ),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      reminderTimes: json['reminder_times'] != null 
          ? parseReminderTimes(json['reminder_times'])
          : [],
      noteId: json['note_id'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'exam_date': examDate.toIso8601String(),
      'exam_hour': examTime.hour,
      'exam_minute': examTime.minute,
      'notifications_enabled': notificationsEnabled,
      'reminder_times': reminderTimes.map((time) => time.toIso8601String()).toList(),
      'note_id': noteId,
      'tags': tags,
    };
  }

  ExamModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? examDate,
    TimeOfDay? examTime,
    bool? notificationsEnabled,
    List<DateTime>? reminderTimes,
    String? noteId,
    List<String>? tags,
  }) {
    return ExamModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      examDate: examDate ?? this.examDate,
      examTime: examTime ?? this.examTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      noteId: noteId ?? this.noteId,
      tags: tags ?? this.tags,
    );
  }

  DateTime get fullExamDateTime {
    return DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
      examTime.hour,
      examTime.minute,
    );
  }

  String get formattedExamDate {
    return DateFormat('MMM dd, yyyy').format(examDate);
  }

  String get formattedExamTime {
    final hour = examTime.hour.toString().padLeft(2, '0');
    final minute = examTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get isPast {
    return DateTime.now().isAfter(fullExamDateTime);
  }

  int get daysUntilExam {
    final now = DateTime.now();
    return examDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}


