import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/data/providers/ai_provider.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class McqController extends GetxController {
  final AIProvider _aiProvider = AIProvider();
  final NoteService _noteService = Get.find<NoteService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxString selectedNoteId = ''.obs;
  final RxInt numberOfQuestions = 5.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> generatedMcqs = <Map<String, dynamic>>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt selectedAnswerIndex = (-1).obs;
  final RxBool showResult = false.obs;
  final RxInt correctAnswers = 0.obs;
  final RxList<bool> questionResults = <bool>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }
  
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      await _noteService.fetchNotes();
      notes.value = _noteService.notes;
    } catch (e) {
      print('Error loading notes: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void selectNote(String noteId) {
    selectedNoteId.value = noteId;
  }
  
  void updateNumberOfQuestions(int number) {
    numberOfQuestions.value = number;
  }
  
  NoteModel? getSelectedNote() {
    if (selectedNoteId.isEmpty) return null;
    
    try {
      return notes.firstWhere((note) => note.id == selectedNoteId.value);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> generateMCQs() async {
    if (selectedNoteId.isEmpty) {
      showErrorSnackbar('Error', 'Please select a note first');
      return false;
    }
    
    if (numberOfQuestions.value <= 0) {
      showErrorSnackbar('Error', 'Please select a valid number of questions');
      return false;
    }
    
    if (!_authService.canUseAIFeatures) {
      showUpgradeDialog();
      return false;
    }
    
    try {
      isGenerating.value = true;
      
      final selectedNote = await _noteService.getNoteById(selectedNoteId.value);
      if (selectedNote == null) {
        showErrorSnackbar('Error', 'Selected note not found');
        return false;
      }
      
      final mcqs = await _aiProvider.generateMCQs(
        selectedNote.content,
        numberOfQuestions.value,
      );
      
      generatedMcqs.value = mcqs;
      
      // Reset quiz state
      currentQuestionIndex.value = 0;
      selectedAnswerIndex.value = -1;
      showResult.value = false;
      correctAnswers.value = 0;
      questionResults.value = List.filled(generatedMcqs.length, false);
      
      // Increment AI query usage
      await _authService.incrementQueryCount();
      
      return true;
    } catch (e) {
      showErrorSnackbar('Generation Failed', 'Error generating MCQs: ${e.toString()}');
      return false;
    } finally {
      isGenerating.value = false;
    }
  }
  
  void selectAnswer(int index) {
    if (showResult.value) return;
    selectedAnswerIndex.value = index;
  }
  
  void checkAnswer() {
    if (generatedMcqs.isEmpty || 
        currentQuestionIndex.value >= generatedMcqs.length ||
        selectedAnswerIndex.value < 0) {
      return;
    }
    
    final correctIndex = generatedMcqs[currentQuestionIndex.value]['correctAnswer'];
    final isCorrect = selectedAnswerIndex.value == correctIndex;
    
    if (isCorrect) {
      correctAnswers.value++;
    }
    
    questionResults[currentQuestionIndex.value] = isCorrect;
    showResult.value = true;
  }
  
  void nextQuestion() {
    if (currentQuestionIndex.value < generatedMcqs.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswerIndex.value = -1;
      showResult.value = false;
    }
  }
  
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      selectedAnswerIndex.value = -1;
      showResult.value = false;
    }
  }
  
  void resetQuiz() {
    generatedMcqs.clear();
    currentQuestionIndex.value = 0;
    selectedAnswerIndex.value = -1;
    showResult.value = false;
    correctAnswers.value = 0;
    questionResults.clear();
  }
  
  String getCurrentQuestionText() {
    if (generatedMcqs.isEmpty || currentQuestionIndex.value >= generatedMcqs.length) {
      return '';
    }
    
    return generatedMcqs[currentQuestionIndex.value]['question'];
  }
  
  List<String> getCurrentOptions() {
    if (generatedMcqs.isEmpty || currentQuestionIndex.value >= generatedMcqs.length) {
      return [];
    }
    
    return List<String>.from(generatedMcqs[currentQuestionIndex.value]['options']);
  }
  
  int getCorrectAnswerIndex() {
    if (generatedMcqs.isEmpty || currentQuestionIndex.value >= generatedMcqs.length) {
      return -1;
    }
    
    return generatedMcqs[currentQuestionIndex.value]['correctAnswer'];
  }
  
  double getScore() {
    if (generatedMcqs.isEmpty) return 0.0;
    return (correctAnswers.value / generatedMcqs.length) * 100;
  }
  
  void showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Upgrade Required'),
        content: const Text(
          'You\'ve reached your daily free usage limit for AI features. '
          'Upgrade to a premium plan for unlimited MCQ generation and more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/subscription');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
  
  int get remainingQueries => _authService.remainingQueries;
  
  bool get canUseAIFeatures => _authService.canUseAIFeatures;
}
