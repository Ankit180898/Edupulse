import 'dart:async';
import 'dart:math';

import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a success snackbar safely (after build completes)
void showSuccessSnackbar(String title, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  });
}

/// Shows an error snackbar safely (after build completes)
void showErrorSnackbar(String title, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  });
}

/// Shows an info snackbar safely (after build completes)
void showInfoSnackbar(String title, String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  });
}

/// Safe version of Get.snackbar with additional customization
void showCustomSnackbar({
  required String title,
  required String message,
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
  Duration? duration,
  SnackPosition? position,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  });
}

/// Formats date to 'MMM d, yyyy' (e.g. 'Jan 1, 2023')
String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

/// Formats date and time to 'MMM d, yyyy • h:mm a' (e.g. 'Jan 1, 2023 • 2:30 PM')
String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
}

/// Formats time to 'h:mm a' (e.g. '2:30 PM')
String formatTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}

/// Gets relative time string (e.g. "2 hours ago")
String getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    return 'Just now';
  }
}

/// Truncates text with ellipsis if longer than maxLength
String truncateWithEllipsis(String text, int maxLength) {
  assert(maxLength >= 3, 'maxLength must be at least 3 for ellipsis');
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

/// Launches URL with error handling
Future<void> launchURL(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showErrorSnackbar('Error', 'Could not launch $url');
    }
  } catch (e) {
    showErrorSnackbar('Error', 'Failed to launch URL: ${e.toString()}');
  }
}

/// Formats file size in human-readable format
String formatFileSize(int bytes, [int decimals = 1]) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

/// Gets file extension from filename
String getFileExtension(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
  return fileName.substring(dotIndex + 1).toLowerCase();
}

/// Gets appropriate icon for file type
IconData getFileIcon(String fileName) {
  final extension = getFileExtension(fileName);
  
  switch (extension) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return Icons.image;
    case 'mp3':
    case 'wav':
    case 'ogg':
      return Icons.music_note;
    case 'mp4':
    case 'avi':
    case 'mov':
    case 'mkv':
      return Icons.video_file;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.folder_zip;
    case 'txt':
      return Icons.text_snippet;
    case 'html':
    case 'htm':
      return Icons.html;
    case 'css':
      return Icons.css;
    case 'js':
      return Icons.javascript;
    default:
      return Icons.insert_drive_file;
  }
}

/// Estimates reading time for text (200 words per minute)
String calculateReadingTime(String text) {
  if (text.isEmpty) return '0 min read';
  
  final wordCount = text.trim().split(RegExp(r'\s+')).length;
  final minutes = (wordCount / 200).ceil();
  
  if (minutes <= 1) return '1 min read';
  return '$minutes mins read';
}

/// Generates a consistent color from a string (for tags, avatars, etc.)
Color getColorFromString(String str) {
  if (str.isEmpty) return Colors.grey;
  
  final colors = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.pink.shade400,
    Colors.indigo.shade400,
    Colors.amber.shade600,
    Colors.deepOrange.shade400,
    Colors.cyan.shade400,
    Colors.lightBlue.shade400,
    Colors.lightGreen.shade400,
  ];
  
  final hash = str.hashCode.abs();
  return colors[hash % colors.length];
}

/// Gets initials from a name (e.g. "John Doe" -> "JD")
String getInitials(String name) {
  if (name.isEmpty) return '';
  
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) {
    try {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } catch (e) {
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
  }
  
  return name.substring(0, min(2, name.length)).toUpperCase();
}

/// Gets a contrasting text color for a background color
Color getContrastColor(Color backgroundColor) {
  // Calculate the perceptive luminance
  final luminance = backgroundColor.computeLuminance();
  // Return black for light colors and white for dark colors
  return luminance > 0.5 ? Colors.black : Colors.white;
}

/// Creates a color swatch from a base color
MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

/// Returns the smaller of two integers
int min(int a, int b) => a < b ? a : b;

/// Returns the larger of two integers
int max(int a, int b) => a > b ? a : b;

/// Capitalizes the first letter of each word in a string
String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Validates an email address format
bool isValidEmail(String email) {
  return RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  ).hasMatch(email);
}

/// Formats a duration in HH:MM:SS format
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return [
    if (hours > 0) hours.toString().padLeft(2, '0'),
    minutes.toString().padLeft(2, '0'),
    seconds.toString().padLeft(2, '0'),
  ].join(':');
}

/// Debounces a function to prevent rapid firing
Function debounce(Function fn, [Duration delay = const Duration(milliseconds: 300)]) {
  Timer? timer;
  return () {
    timer?.cancel();
    timer = Timer(delay, () => fn());
  };
}