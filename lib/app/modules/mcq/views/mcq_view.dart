import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/empty_state_widget.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/mcq/controllers/mcq_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/percent_indicator.dart';

class McqView extends GetView<McqController> {
  const McqView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'MCQ Quiz',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        if (controller.generatedMcqs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.quiz,
            title: 'No MCQs Generated Yet',
            message: 'Generate MCQs from your notes to test your knowledge',
            buttonText: 'Generate MCQs',
            onButtonPressed: () => Get.toNamed('/mcq-generate'),
          );
        }
        
        return _buildQuizContent();
      }),
      bottomNavigationBar: Obx(() {
        if (controller.generatedMcqs.isEmpty) {
          return Container();
        }
        
        return _buildNavigationBar();
      }),
    );
  }

  Widget _buildQuizContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              _buildQuizHeader(),
              const SizedBox(height: 24),
              _buildQuestion(),
              const SizedBox(height: 24),
              _buildOptions(),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    final totalQuestions = controller.generatedMcqs.length;
    final currentQuestion = controller.currentQuestionIndex.value + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Question $currentQuestion of $totalQuestions',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Reset Quiz'),
                    content: const Text('Are you sure you want to reset this quiz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed('/mcq-generate');
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: currentQuestion / totalQuestions,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Question',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.getCurrentQuestionText(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final options = controller.getCurrentOptions();
    final selectedIndex = controller.selectedAnswerIndex.value;
    final correctIndex = controller.showResult.value ? controller.getCorrectAnswerIndex() : -1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            Color backgroundColor;
            Color borderColor;
            IconData? trailingIcon;
            
            if (controller.showResult.value) {
              if (index == correctIndex) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                trailingIcon = Icons.check_circle;
              } else if (index == selectedIndex && index != correctIndex) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
                trailingIcon = Icons.cancel;
              } else {
                backgroundColor = Colors.white;
                borderColor = Colors.grey.shade300;
                trailingIcon = null;
              }
            } else {
              backgroundColor = selectedIndex == index
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white;
              borderColor = selectedIndex == index
                  ? AppColors.primaryColor
                  : Colors.grey.shade300;
              trailingIcon = selectedIndex == index ? Icons.check_circle : null;
            }
            
            return InkWell(
              onTap: controller.showResult.value ? null : () => controller.selectAnswer(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: controller.showResult.value && index == correctIndex
                            ? Colors.green
                            : controller.showResult.value && index == selectedIndex && index != correctIndex
                                ? Colors.red
                                : selectedIndex == index && !controller.showResult.value
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D...
                        style: TextStyle(
                          color: (controller.showResult.value && (index == correctIndex || (index == selectedIndex && index != correctIndex))) ||
                                  (selectedIndex == index && !controller.showResult.value)
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        options[index],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(
                        trailingIcon,
                        color: index == correctIndex
                            ? Colors.green
                            : index == selectedIndex && index != correctIndex
                                ? Colors.red
                                : AppColors.primaryColor,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (controller.showResult.value) {
      if (controller.currentQuestionIndex.value < controller.generatedMcqs.length - 1) {
        return CustomButton(
          text: 'Next Question',
          onPressed: controller.nextQuestion,
          icon: const Icon(Icons.arrow_forward, size: 18),
          fullWidth: true,
        );
      } else {
        return CustomButton(
          text: 'See Results',
          onPressed: () => _showResultsDialog(),
          icon: const Icon(Icons.emoji_events, size: 18),
          fullWidth: true,
          backgroundColor: Colors.green,
        );
      }
    } else {
      return CustomButton(
        text: 'Check Answer',
        onPressed: controller.selectedAnswerIndex.value >= 0 
            ? controller.checkAnswer 
            : null,
        fullWidth: true,
      );
    }
  }
  
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.currentQuestionIndex.value > 0
                ? controller.previousQuestion
                : null,
            color: controller.currentQuestionIndex.value > 0
                ? AppColors.primaryColor
                : Colors.grey,
          ),
          Text(
            '${controller.currentQuestionIndex.value + 1} / ${controller.generatedMcqs.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: controller.currentQuestionIndex.value < controller.generatedMcqs.length - 1
                ? controller.nextQuestion
                : null,
            color: controller.currentQuestionIndex.value < controller.generatedMcqs.length - 1
                ? AppColors.primaryColor
                : Colors.grey,
          ),
        ],
      ),
    );
  }
  
  void _showResultsDialog() {
    final score = controller.getScore();
    final total = controller.generatedMcqs.length;
    final correct = controller.correctAnswers.value;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Quiz Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: score / 100,
              center: Text(
                '${score.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              progressColor: score >= 70 ? Colors.green : (score >= 40 ? Colors.orange : Colors.red),
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 24),
            Text(
              'You answered $correct out of $total questions correctly',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              score >= 70
                  ? 'Great job! 🎉'
                  : score >= 40
                      ? 'Good effort! Keep practicing 💪'
                      : 'Keep studying, you\'ll improve! 📚',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetQuiz();
              Get.toNamed('/mcq-generate');
            },
            child: const Text('New Quiz'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Review Quiz'),
          ),
        ],
      ),
    );
  }
}
