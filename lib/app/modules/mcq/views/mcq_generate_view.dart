import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/empty_state_widget.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/mcq/controllers/mcq_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class McqGenerateView extends GetView<McqController> {
  const McqGenerateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If arguments contain a noteId, pre-select that note
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String preSelectedNoteId = args['noteId'] ?? '';
    
    if (preSelectedNoteId.isNotEmpty && controller.selectedNoteId.isEmpty) {
      controller.selectNote(preSelectedNoteId);
    }
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Generate MCQs',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        if (controller.isGenerating.value) {
          return _buildGeneratingView();
        }
        
        if (controller.notes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.note_alt_outlined,
            title: 'No Notes Available',
            message: 'Add notes first to generate MCQs',
            buttonText: 'Add Note',
            onButtonPressed: () => Get.toNamed('/note-add'),
          );
        }
        
        return _buildForm();
      }),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildNoteSelection(),
          const SizedBox(height: 24),
          _buildQuestionCount(),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Generate MCQs',
            onPressed: _generateMCQs,
            isLoading: controller.isGenerating.value,
            fullWidth: true,
            icon: const Icon(Icons.auto_awesome, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: AppColors.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.infoColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI will generate multiple-choice questions based on your notes to test your knowledge. Select a note and specify how many questions you want to generate.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have ${controller.remainingQueries} AI queries left today',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
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
          'Select Note',
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
        if (controller.selectedNoteId.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getSelectedNote()?.title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.getSelectedNote()?.content ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: controller.numberOfQuestions.value.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                label: controller.numberOfQuestions.value.toString(),
                onChanged: (value) => controller.updateNumberOfQuestions(value.toInt()),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${controller.numberOfQuestions.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
            'Generating MCQs...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Our AI is analyzing your notes and creating challenging questions for you.',
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

  Future<void> _generateMCQs() async {
    final success = await controller.generateMCQs();
    
    if (success) {
      Get.toNamed('/mcq');
    }
  }
}
