import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/custom_text_field.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/flashcards/controllers/flashcards_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FlashcardAddView extends GetView<FlashcardsController> {
  const FlashcardAddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String flashcardId = args['flashcardId'] ?? '';
    final bool isEditing = args['isEditing'] ?? false;
    final String preSelectedNoteId = args['noteId'] ?? '';
    
    if (isEditing && flashcardId.isNotEmpty && controller.currentFlashcardId.value != flashcardId) {
      controller.loadFlashcardData(flashcardId);
    } else if (!isEditing && controller.currentFlashcardId.value.isNotEmpty) {
      // Reset fields when creating a new flashcard
      controller.resetFields();
      
      // If a note ID is provided, select it
      if (preSelectedNoteId.isNotEmpty) {
        controller.selectNote(preSelectedNoteId);
      }
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Flashcard' : 'Create Flashcard',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        if (controller.isGenerating.value) {
          return _buildGeneratingView();
        }
        
        return _buildForm(isEditing);
      }),
    );
  }

  Widget _buildForm(bool isEditing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEditing) _buildAIGenerationOption(),
          const SizedBox(height: 24),
          _buildNoteSelection(),
          const SizedBox(height: 24),
          _buildQuestionField(),
          const SizedBox(height: 24),
          _buildAnswerField(),
          const SizedBox(height: 24),
          _buildHintField(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 32),
          CustomButton(
            text: isEditing ? 'Update Flashcard' : 'Create Flashcard',
            onPressed: controller.saveFlashcard,
            isLoading: controller.isLoading.value,
            fullWidth: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAIGenerationOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Flashcard Generation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Let AI create flashcards from your notes automatically. Select a note and number of flashcards to generate.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedNoteId.value.isNotEmpty
                          ? controller.selectedNoteId.value
                          : null,
                      hint: const Text('Select a note'),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(8),
                      items: controller.notes.map((note) {
                        return DropdownMenuItem<String>(
                          value: note.id,
                          child: Text(
                            note.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? noteId) {
                        if (noteId != null) {
                          controller.selectNote(noteId);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.numberOfFlashcards.value,
                      hint: const Text('Count'),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(8),
                      items: [3, 5, 10, 15, 20].map((count) {
                        return DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count'),
                        );
                      }).toList(),
                      onChanged: (int? count) {
                        if (count != null) {
                          controller.updateNumberOfFlashcards(count);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Generate Flashcards',
            onPressed: controller.selectedNoteId.isEmpty 
                ? null 
                : controller.generateFlashcardsFromNote,
            isLoading: controller.isGenerating.value,
            fullWidth: true,
            icon: const Icon(Icons.bolt, size: 18),
            backgroundColor: AppColors.accentColor,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'AI credits left: ${controller.remainingQueries}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Note (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedNoteId.value.isNotEmpty
                  ? controller.selectedNoteId.value
                  : null,
              hint: const Text('Select a note (optional)'),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(8),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('None'),
                ),
                ...controller.notes.map((note) {
                  return DropdownMenuItem<String>(
                    value: note.id,
                    child: Text(
                      note.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ],
              onChanged: (String? noteId) {
                controller.selectNote(noteId ?? '');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.questionController,
          hintText: 'Enter the question or front side of flashcard',
          maxLines: 4,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.answerController,
          hintText: 'Enter the answer or back side of flashcard',
          maxLines: 4,
          minLines: 2,
        ),
      ],
    );
  }

  Widget _buildHintField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hint (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.hintController,
          hintText: 'Add a hint for this flashcard (optional)',
          maxLines: 2,
          minLines: 1,
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
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      labelStyle: const TextStyle(color: Colors.purple),
                      deleteIconColor: Colors.purple,
                      onDeleted: () => controller.removeTag(tag),
                    );
                  }).toList(),
                );
        }),
      ],
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(
            color: AppColors.primaryColor,
            size: 60.0,
          ),
          const SizedBox(height: 24),
          const Text(
            'Generating Flashcards...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Our AI is analyzing your notes and creating flashcards to help you study more effectively.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This may take a moment depending on the length of your notes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
