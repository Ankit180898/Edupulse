import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/flashcards/controllers/flashcards_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardDetailView extends GetView<FlashcardsController> {
  const FlashcardDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String flashcardId = args['flashcardId'] ?? '';

    // Use a local variable to prevent unnecessary rebuilds
    final bool needsLoad = flashcardId.isNotEmpty && controller.currentFlashcardId.value != flashcardId;

    if (needsLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadFlashcardData(flashcardId);
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Flashcard',
        showBackButton: true,
        actions: [
          Obx(() {
            if (controller.isLoading.value) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Get.toNamed(
                      '/flashcard-add',
                      arguments: {'flashcardId': flashcardId, 'isEditing': true},
                    );
                    break;
                  case 'delete':
                    controller.deleteFlashcard(flashcardId);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return Column(
          children: [
            Expanded(
              child: _buildFlashcard(),
            ),
            _buildNavigation(),
          ],
        );
      }),
    );
  }

  Widget _buildFlashcard() {
    return GestureDetector(
      onTap: controller.toggleAnswer,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: controller.showAnswer.value ? _buildAnswerSide() : _buildQuestionSide(),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionSide() {
    return Container(
      key: const ValueKey<String>('question'),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.help_outline,
            size: 48,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          const Text(
            'QUESTION',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  controller.questionController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (controller.hintController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Text(
                    'HINT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.hintController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Tap to reveal answer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSide() {
    return Container(
      key: const ValueKey<String>('answer'),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'ANSWER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  controller.answerController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'How well did you know this?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildFamiliarityRating(),
          const SizedBox(height: 16),
          const Text(
            'Tap to see question',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamiliarityRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final level = index + 1;
        Color color;

        switch (level) {
          case 1:
            color = Colors.red;
          case 2:
            color = Colors.orange;
          case 3:
            color = Colors.amber;
          case 4:
            color = Colors.lightGreen;
          case 5:
            color = Colors.green;
          default:
            color = Colors.grey;
        }

        return GestureDetector(
          onTap: () => controller.updateFamiliarity(controller.currentFlashcardId.value, level),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigation() {
    return Obx(() {
      final currentIndex = controller.currentCardIndex.value;
      final studyListLength = controller.studyList.length;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(
              text: 'Previous',
              onPressed: currentIndex > 0 ? controller.previousCard : null,
              icon: const Icon(Icons.arrow_back, size: 18),
              backgroundColor: Colors.grey.shade200,
              textColor: AppColors.primaryTextColor,
              borderColor: Colors.grey.shade300,
            ),
            Text(
              '${currentIndex + 1} / $studyListLength',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            CustomButton(
              text: 'Next',
              onPressed: currentIndex < studyListLength - 1 ? controller.nextCard : null,
              icon: const Icon(Icons.arrow_forward, size: 18),
            ),
          ],
        ),
      );
    });
  }
}
