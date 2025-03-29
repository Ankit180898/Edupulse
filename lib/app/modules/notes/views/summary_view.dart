import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/notes/controllers/notes_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SummaryView extends GetView<NotesController> {
  const SummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String noteId = args['noteId'] ?? '';
    
    if (noteId.isNotEmpty && controller.currentNoteId.value != noteId) {
      controller.loadNoteData(noteId);
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Summary',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: controller.summary.value));
              showSuccessSnackbar('Copied', 'Summary copied to clipboard');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        if (controller.isSummarizing.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitPulse(
                  color: AppColors.primaryColor,
                  size: 50.0,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Generating summary...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Our AI is analyzing your notes.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This might take a few moments.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOriginalNote(),
              const SizedBox(height: 24),
              _buildSummary(),
              const SizedBox(height: 24),
              _buildActions(noteId),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOriginalNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Original Note',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.titleController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                truncateWithEllipsis(controller.contentController.text, 150),
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              if (controller.contentController.text.length > 150) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    'View full note',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.accentColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            controller.summary.value,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(String noteId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to do next?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Create Flashcards',
                onPressed: () => Get.toNamed(
                  '/flashcard-add',
                  arguments: {'noteId': noteId},
                ),
                icon: const Icon(Icons.flip, size: 18),
                backgroundColor: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Generate MCQs',
                onPressed: () => Get.toNamed(
                  '/mcq-generate',
                  arguments: {'noteId': noteId},
                ),
                icon: const Icon(Icons.quiz, size: 18),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Extract Key Points',
          onPressed: () {
            Get.back();
            controller.extractKeyPoints(noteId);
          },
          fullWidth: true,
          icon: const Icon(Icons.format_list_bulleted, size: 18),
          backgroundColor: Colors.green,
        ),
      ],
    );
  }
}
