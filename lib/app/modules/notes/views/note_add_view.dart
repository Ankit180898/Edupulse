import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/custom_text_field.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/notes/controllers/notes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteAddView extends GetView<NotesController> {
  const NoteAddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String noteId = args['noteId'] ?? '';
    final bool isEditing = args['isEditing'] ?? false;

    // Handle loading only once when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEditing && noteId.isNotEmpty) {
        if (controller.currentNoteId.value != noteId) {
          controller.loadNoteData(noteId);
        }
      } else if (!isEditing) {
        // Only reset if we're creating a new note
        controller.resetFields();
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Note' : 'Add New Note',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && isEditing) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildContentField(),
              const SizedBox(height: 20),
              _buildTagsSection(),
              const SizedBox(height: 20),
              _buildFileUploadSection(),
              const SizedBox(height: 40),
              CustomButton(
                text: isEditing ? 'Update Note' : 'Save Note',
                onPressed: controller.saveNote,
                isLoading: controller.isLoading.value,
                fullWidth: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.titleController,
          hintText: 'Enter note title',
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.contentController,
          hintText: 'Enter note content',
          maxLines: 10,
          minLines: 5,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.tagController,
                hintText: 'Add tags',
                maxLines: 1,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.addTag,
                ),
                onSubmitted: (_) => controller.addTag(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          return controller.selectedTags.isEmpty
              ? Text(
                  'No tags added yet',
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.accentColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppColors.accentColor),
                      deleteIconColor: AppColors.accentColor,
                      onDeleted: () => controller.removeTag(tag),
                    );
                  }).toList(),
                );
        }),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach File (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return controller.selectedFileName.isEmpty
              ? OutlinedButton.icon(
                  onPressed: controller.pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.selectedFileName.value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: controller.removeFile,
                      ),
                    ],
                  ),
                );
        }),
      ],
    );
  }
}
