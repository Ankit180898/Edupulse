import 'package:flutter/material.dart';

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format(BuildContext context) {
    final String hourString = hour.toString().padLeft(2, '0');
    final String minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}