import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/models/flashcard_model.dart';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/flashcard_service.dart';
import 'package:edupulse/app/data/services/note_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FlashcardsController extends GetxController {
  final FlashcardService _flashcardService = Get.find<FlashcardService>();
  final NoteService _noteService = Get.find<NoteService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController hintController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  
  final RxList<String> selectedTags = <String>[].obs;
  final RxString selectedNoteId = ''.obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxBool showAnswer = false.obs;
  final RxString currentFlashcardId = ''.obs;
  final RxInt currentCardIndex = 0.obs;
  final RxInt numberOfFlashcards = 5.obs;
  final RxList<FlashcardModel> studyList = <FlashcardModel>[].obs;
  final RxString filterTag = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchFlashcards();
    loadNotes();
  }
  
  @override
  void onClose() {
    questionController.dispose();
    answerController.dispose();
    hintController.dispose();
    tagController.dispose();
    super.onClose();
  }
  
  void resetFields() {
    questionController.clear();
    answerController.clear();
    hintController.clear();
    tagController.clear();
    selectedTags.clear();
    selectedNoteId.value = '';
    currentFlashcardId.value = '';
    showAnswer.value = false;
  }
  
  Future<void> fetchFlashcards() async {
    await _flashcardService.fetchFlashcards();
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
  
  List<FlashcardModel> get flashcards {
    if (searchQuery.isEmpty && filterTag.isEmpty) {
      return _flashcardService.flashcards;
    } else {
      return _flashcardService.flashcards.where((flashcard) {
        bool matchesSearch = searchQuery.isEmpty ||
                            flashcard.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            flashcard.answer.toLowerCase().contains(searchQuery.toLowerCase());
        
        bool matchesTag = filterTag.isEmpty ||
                          flashcard.tags.contains(filterTag.value);
        
        return matchesSearch && matchesTag;
      }).toList();
    }
  }
  
  List<FlashcardModel> get flashcardsForReview {
    return _flashcardService.getFlashcardsForReview();
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void setFilterTag(String tag) {
    if (filterTag.value == tag) {
      filterTag.value = ''; // Clear filter if same tag clicked
    } else {
      filterTag.value = tag;
    }
  }
  
  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !selectedTags.contains(tag)) {
      selectedTags.add(tag);
      tagController.clear();
    }
  }
  
  void removeTag(String tag) {
    selectedTags.remove(tag);
  }
  
  void selectNote(String noteId) {
    selectedNoteId.value = noteId;
    
    // If a note is selected, load its tags
    if (noteId.isNotEmpty) {
      final selectedNote = notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => NoteModel(
          id: '',
          userId: '',
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tags: [],
        ),
      );
      
      if (selectedNote.id.isNotEmpty) {
        selectedTags.value = [...selectedNote.tags];
      }
    }
  }
  
  void updateNumberOfFlashcards(int number) {
    numberOfFlashcards.value = number;
  }
  
  NoteModel? getSelectedNote() {
    if (selectedNoteId.isEmpty) return null;
    
    try {
      return notes.firstWhere((note) => note.id == selectedNoteId.value);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> loadFlashcardData(String flashcardId) async {
    try {
      isLoading.value = true;
      
      final flashcard = await _flashcardService.getFlashcardById(flashcardId);
      if (flashcard != null) {
        currentFlashcardId.value = flashcard.id;
        questionController.text = flashcard.question;
        answerController.text = flashcard.answer;
        hintController.text = flashcard.hint ?? '';
        selectedTags.value = flashcard.tags;
        selectedNoteId.value = flashcard.noteId ?? '';
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error loading flashcard: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> saveFlashcard() async {
    if (questionController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Question is required');
      return;
    }
    
    if (answerController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Answer is required');
      return;
    }
    
    try {
      isLoading.value = true;
      
      bool success;
      if (currentFlashcardId.value.isEmpty) {
        // Create new flashcard
        success = await _flashcardService.createFlashcard(
          questionController.text,
          answerController.text,
          hintController.text.isEmpty ? null : hintController.text,
          selectedTags,
          noteId: selectedNoteId.value.isEmpty ? null : selectedNoteId.value,
        );
      } else {
        // Update existing flashcard
        final flashcard = await _flashcardService.getFlashcardById(currentFlashcardId.value);
        if (flashcard != null) {
          final updatedFlashcard = flashcard.copyWith(
            question: questionController.text,
            answer: answerController.text,
            hint: hintController.text.isEmpty ? null : hintController.text,
            tags: selectedTags,
            noteId: selectedNoteId.value.isEmpty ? null : selectedNoteId.value,
            updatedAt: DateTime.now(),
          );
          
          success = await _flashcardService.updateFlashcard(updatedFlashcard);
        } else {
          throw Exception('Flashcard not found');
        }
      }
      
      if (success) {
        Get.back();
        showSuccessSnackbar(
          'Success',
          currentFlashcardId.value.isEmpty ? 'Flashcard created successfully' : 'Flashcard updated successfully',
        );
        resetFields();
      } else {
        showErrorSnackbar(
          'Error',
          currentFlashcardId.value.isEmpty ? 'Failed to create flashcard' : 'Failed to update flashcard',
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error saving flashcard: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteFlashcard(String flashcardId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this flashcard? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        isLoading.value = true;
        
        final success = await _flashcardService.deleteFlashcard(flashcardId);
        
        if (success) {
          if (Get.currentRoute.contains('/flashcard-detail')) {
            Get.back(); // Go back to flashcards list if we're on detail page
          }
          showSuccessSnackbar('Success', 'Flashcard deleted successfully');
        } else {
          showErrorSnackbar('Error', 'Failed to delete flashcard');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error deleting flashcard: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateFamiliarity(String flashcardId, int familiarity) async {
    try {
      isLoading.value = true;
      
      final success = await _flashcardService.updateFlashcardFamiliarity(flashcardId, familiarity);
      
      if (success) {
        showSuccessSnackbar('Success', 'Familiarity updated successfully');
      } else {
        showErrorSnackbar('Error', 'Failed to update familiarity');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error updating familiarity: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> generateFlashcardsFromNote() async {
    if (selectedNoteId.isEmpty) {
      showErrorSnackbar('Error', 'Please select a note first');
      return false;
    }
    
    if (numberOfFlashcards.value <= 0) {
      showErrorSnackbar('Error', 'Please select a valid number of flashcards');
      return false;
    }
    
    if (!_authService.canUseAIFeatures) {
      showUpgradeDialog();
      return false;
    }
    
    try {
      isGenerating.value = true;
      
      final createdFlashcards = await _flashcardService.generateFlashcardsFromNote(
        selectedNoteId.value,
        numberOfFlashcards.value,
      );
      
      if (createdFlashcards.isNotEmpty) {
        showSuccessSnackbar(
          'Success',
          'Generated ${createdFlashcards.length} flashcards successfully',
        );
        return true;
      } else {
        if (_authService.canUseAIFeatures) {
          showErrorSnackbar('Error', 'Failed to generate flashcards');
        } else {
          showUpgradeDialog();
        }
        return false;
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error generating flashcards: ${e.toString()}');
      return false;
    } finally {
      isGenerating.value = false;
    }
  }
  
  void startStudySession() {
    studyList.value = [...flashcards];
    if (studyList.isNotEmpty) {
      studyList.shuffle(); // Randomize the order
      currentCardIndex.value = 0;
      showAnswer.value = false;
      Get.toNamed('/flashcard-detail', arguments: {'flashcardId': studyList[0].id});
    } else {
      showErrorSnackbar('Error', 'No flashcards available to study');
    }
  }
  
  void startReviewSession() {
    studyList.value = [...flashcardsForReview];
    if (studyList.isNotEmpty) {
      studyList.shuffle(); // Randomize the order
      currentCardIndex.value = 0;
      showAnswer.value = false;
      Get.toNamed('/flashcard-detail', arguments: {'flashcardId': studyList[0].id});
    } else {
      showErrorSnackbar('Info', 'No flashcards need review at this time');
    }
  }
  
  void toggleAnswer() {
    showAnswer.value = !showAnswer.value;
  }
  
  void nextCard() {
    if (currentCardIndex.value < studyList.length - 1) {
      currentCardIndex.value++;
      showAnswer.value = false;
      Get.toNamed('/flashcard-detail', arguments: {'flashcardId': studyList[currentCardIndex.value].id});
    }
  }
  
  void previousCard() {
    if (currentCardIndex.value > 0) {
      currentCardIndex.value--;
      showAnswer.value = false;
      Get.toNamed('/flashcard-detail', arguments: {'flashcardId': studyList[currentCardIndex.value].id});
    }
  }
  
  void showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Upgrade Required'),
        content: const Text(
          'You\'ve reached your daily free usage limit for AI features. '
          'Upgrade to a premium plan for unlimited flashcard generation and more!',
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
  
  Set<String> get allTags {
    final tagSet = <String>{};
    for (final flashcard in _flashcardService.flashcards) {
      tagSet.addAll(flashcard.tags);
    }
    return tagSet;
  }
  
  int get remainingQueries => _authService.remainingQueries;
  
  bool get canUseAIFeatures => _authService.canUseAIFeatures;
}
