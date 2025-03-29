import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/notes/controllers/notes_controller.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NoteDetailView extends GetView<NotesController> {
  const NoteDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String noteId = args['noteId'] ?? '';

       if (noteId.isNotEmpty) {
      // Use Future.microtask to avoid build-time setState
      Future.microtask(() {
        if (controller.currentNoteId.value != noteId) {
          controller.loadNoteData(noteId);
        }
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Note Details',
        showBackButton: true,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                Icons.edit,
                color: controller.isLoading.value ? Colors.grey : null,
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () => Get.toNamed(
                        Routes.NOTE_ADD,
                        arguments: {'noteId': noteId, 'isEditing': true},
                      ),
            );
          }),
          Obx(() {
            return IconButton(
              icon: Icon(
                Icons.delete,
                color: controller.isLoading.value ? Colors.grey : Colors.red,
              ),
              onPressed: controller.isLoading.value ? null : () => controller.deleteNote(noteId),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildContent(),
              const SizedBox(height: 24),
              _buildTags(),
              const SizedBox(height: 24),
              _buildActionButtons(noteId),
              if (controller.showKeyPoints.value) ...[
                const SizedBox(height: 24),
                _buildKeyPoints(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.titleController.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.secondaryTextColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Last updated: ${DateFormat('MMM d, yyyy, h:mm a').format(DateTime.now())}',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        controller.contentController.text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => controller.selectedTags.isEmpty
            ? Text(
                'No tags added',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.selectedTags
                    .map((tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => controller.removeTag(tag),
                        ))
                    .toList(),
              )),
      ],
    );
  }

  Widget _buildActionButtons(String noteId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
              'You have ${controller.remainingQueries.value} AI queries left today',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryTextColor,
              ),
            )),
        const SizedBox(height: 16),
        Obx(() {
          // Check if any AI action is in progress
          bool isAnyActionInProgress = controller.isSummarizing.value || controller.isExtractingKeyPoints.value;
          bool hasNoQueries = controller.remainingQueries.value <= 0;

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomButton(
                          text: 'Generate Summary',
                          onPressed:
                              (isAnyActionInProgress || hasNoQueries) ? null : () => controller.generateSummary(noteId),
                          isLoading: controller.isSummarizing.value,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          backgroundColor: AppColors.accentColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomButton(
                          text: 'Extract Key Points',
                          onPressed: (isAnyActionInProgress || hasNoQueries)
                              ? null
                              : () => controller.extractKeyPoints(noteId),
                          isLoading: controller.isExtractingKeyPoints.value,
                          icon: const Icon(Icons.format_list_bulleted, size: 18),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomButton(
                          text: 'Create Flashcards',
                          onPressed: hasNoQueries
                              ? null
                              : () => Get.toNamed(
                                    Routes.FLASHCARD_ADD,
                                    arguments: {'noteId': noteId},
                                  ),
                          icon: const Icon(Icons.flip, size: 18),
                          backgroundColor: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomButton(
                          text: 'Generate MCQs',
                          onPressed: hasNoQueries
                              ? null
                              : () => Get.toNamed(
                                    Routes.MCQ_GENERATE,
                                    arguments: {'noteId': noteId},
                                  ),
                          icon: const Icon(Icons.quiz, size: 18),
                          backgroundColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildKeyPoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Key Points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => controller.showKeyPoints.value = false,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Obx(() {
            if (controller.isExtractingKeyPoints.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (controller.keyPoints.isEmpty) {
              return const Center(
                child: Text("No key points to display"),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.keyPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          }),
        ),
      ],
    );
  }
}
