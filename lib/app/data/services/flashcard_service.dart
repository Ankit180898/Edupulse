import 'package:edupulse/app/data/models/flashcard_model.dart';
import 'package:edupulse/app/data/providers/ai_provider.dart';
import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class FlashcardService extends GetxService {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  final AIProvider _aiProvider = AIProvider();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxList<FlashcardModel> flashcards = <FlashcardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchFlashcards();
  }
  
   Future<void> fetchFlashcards() async {
    try {
      isLoading.value = true;
      final fetchedFlashcards = await _supabaseProvider.getFlashcards();
      // Clear existing flashcards before adding to prevent duplication
      flashcards.clear();
      flashcards.assignAll(fetchedFlashcards);
    } catch (e) {
      print('Error fetching flashcards: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<FlashcardModel?> getFlashcardById(String id) async {
    try {
      // Check local cache first
      final localFlashcard = flashcards.firstWhereOrNull((f) => f.id == id);
      if (localFlashcard != null) return localFlashcard;
      
      return await _supabaseProvider.getFlashcardById(id);
    } catch (e) {
      print('Error getting flashcard by ID: $e');
      return null;
    }
  }
  
  Future<List<FlashcardModel>> getFlashcardsByNoteId(String noteId) async {
    try {
      return await _supabaseProvider.getFlashcardsByNoteId(noteId);
    } catch (e) {
      print('Error getting flashcards by note ID: $e');
      return [];
    }
  }
  
   Future<bool> createFlashcard(String question, String answer, String? hint, List<String> tags, {String? noteId}) async {
    try {
      isLoading.value = true;
      
      final newFlashcard = FlashcardModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser.value!.id,
        question: question,
        answer: answer,
        hint: hint,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        noteId: noteId,
      );
      
      final createdFlashcard = await _supabaseProvider.createFlashcard(newFlashcard);
      
      // Check if flashcard exists locally before adding
      final existingIndex = flashcards.indexWhere((f) => f.id == createdFlashcard.id);
      if (existingIndex != -1) {
        flashcards[existingIndex] = createdFlashcard;
      } else {
        flashcards.add(createdFlashcard);
      }
      
      return true;
    } catch (e) {
      print('Error creating flashcard: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateFlashcard(FlashcardModel flashcard) async {
    try {
      isLoading.value = true;
      
      final updatedFlashcard = flashcard.copyWith(updatedAt: DateTime.now());
      await _supabaseProvider.updateFlashcard(updatedFlashcard);
      
      final index = flashcards.indexWhere((f) => f.id == flashcard.id);
      if (index != -1) {
        flashcards[index] = updatedFlashcard;
        flashcards.refresh();
      }
      
      return true;
    } catch (e) {
      print('Error updating flashcard: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteFlashcard(String id) async {
    try {
      isLoading.value = true;
      await _supabaseProvider.deleteFlashcard(id);
      flashcards.removeWhere((flashcard) => flashcard.id == id);
      return true;
    } catch (e) {
      print('Error deleting flashcard: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateFlashcardFamiliarity(String id, int familiarity) async {
    try {
      final flashcard = await getFlashcardById(id);
      if (flashcard == null) return false;
      
      final updatedFlashcard = flashcard.copyWith(
        familiarity: familiarity,
        lastReviewed: DateTime.now(),
      );
      
      return await updateFlashcard(updatedFlashcard);
    } catch (e) {
      print('Error updating flashcard familiarity: $e');
      return false;
    }
  }
  
 Future<List<FlashcardModel>> generateFlashcardsFromNote(String noteId, int count) async {
    try {
      isGenerating.value = true;
      
      if (!_authService.canUseAIFeatures) {
        return [];
      }
      
      final note = await _supabaseProvider.getNoteById(noteId);
      if (note == null) return [];
      
      final generatedFlashcards = await _aiProvider.generateFlashcards(note.content, count);
      
      final List<FlashcardModel> createdFlashcards = [];
      
      for (final flashcard in generatedFlashcards) {
        final newFlashcard = FlashcardModel(
          id: const Uuid().v4(),
          userId: _authService.currentUser.value!.id,
          question: flashcard['question'],
          answer: flashcard['answer'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          tags: note.tags,
          noteId: noteId,
        );
        
        final createdFlashcard = await _supabaseProvider.createFlashcard(newFlashcard);
        createdFlashcards.add(createdFlashcard);
        
        // Check if flashcard exists locally before adding
        final existingIndex = flashcards.indexWhere((f) => f.id == createdFlashcard.id);
        if (existingIndex != -1) {
          flashcards[existingIndex] = createdFlashcard;
        } else {
          flashcards.add(createdFlashcard);
        }
      }
      
      return createdFlashcards;
    } catch (e) {
      print('Error generating flashcards: $e');
      return [];
    } finally {
      isGenerating.value = false;
    }
  }
  
  List<FlashcardModel> getFlashcardsForReview() {
    return flashcards.where((flashcard) => flashcard.needsReview).toList();
  }
}
