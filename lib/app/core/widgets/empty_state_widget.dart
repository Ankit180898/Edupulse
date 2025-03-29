import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:edupulse/app/core/values/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showButton;
  final double iconSize;
  final Color? iconColor;
  final bool animate;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.showButton = true,
    this.iconSize = 80,
    this.iconColor,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
      ? const Color(0xFF1E1E1E) 
      : Colors.white;
    final titleColor = isDarkMode 
      ? Colors.white 
      : AppColors.primaryTextColor;
    final messageColor = isDarkMode 
      ? Colors.grey.shade300 
      : AppColors.secondaryTextColor;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode 
            ? null 
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              transform: animate 
                ? Matrix4.translationValues(0, -10, 0)
                : Matrix4.identity(),
              child: Icon(
                icon,
                color: iconColor ?? (isDarkMode 
                  ? Colors.white 
                  : AppColors.secondaryTextColor),
                size: iconSize,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                icon: Icon(getActionIcon(), size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData getActionIcon() {
    // Get appropriate icon for the action button based on the context
    if (buttonText == null) return Icons.add;

    final text = buttonText!.toLowerCase();
    
    if (text.contains('add') || text.contains('create')) {
      return Icons.add;
    } else if (text.contains('refresh') || text.contains('reload')) {
      return Icons.refresh;
    } else if (text.contains('try')) {
      return Icons.refresh;
    } else if (text.contains('upload')) {
      return Icons.upload_file;
    } else if (text.contains('search')) {
      return Icons.search;
    } else if (text.contains('import')) {
      return Icons.download;
    } else if (text.contains('scan')) {
      return Icons.document_scanner;
    } else if (text.contains('explore')) {
      return Icons.explore;
    } else if (text.contains('get started')) {
      return Icons.arrow_forward;
    }
    
    return Icons.arrow_forward;
  }

  // All factory constructors remain the same as in the original implementation
  factory EmptyStateWidget.notes({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.note_alt_outlined,
      title: 'No Notes Yet',
      message: 'Add your first note to get started',
      buttonText: 'Add Note',
      onButtonPressed: onAddPressed,
    );
  }

  factory EmptyStateWidget.flashcards({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.flip,
      title: 'No Flashcards Yet',
      message: 'Create your first flashcard to get started',
      buttonText: 'Create Flashcard',
      onButtonPressed: onAddPressed,
    );
  }

  factory EmptyStateWidget.mcqs({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.quiz,
      title: 'No MCQs Generated Yet',
      message: 'Generate MCQs from your notes to test your knowledge',
      buttonText: 'Generate MCQs',
      onButtonPressed: onAddPressed,
    );
  }

  factory EmptyStateWidget.exams({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.event_note,
      title: 'No Exams Yet',
      message: 'Add your first exam to get reminders',
      buttonText: 'Add Exam',
      onButtonPressed: onAddPressed,
    );
  }

  factory EmptyStateWidget.search({VoidCallback? onResetPressed}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try a different search term or clear filters',
      buttonText: 'Reset Search',
      onButtonPressed: onResetPressed,
    );
  }

  factory EmptyStateWidget.noInternet({VoidCallback? onRetryPressed}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your connection and try again',
      buttonText: 'Retry',
      onButtonPressed: onRetryPressed,
      iconColor: AppColors.errorColor,
    );
  }

  factory EmptyStateWidget.custom({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    bool showButton = true,
    double iconSize = 80,
    Color? iconColor,
  }) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      showButton: showButton,
      iconSize: iconSize,
      iconColor: iconColor,
    );
  }
}