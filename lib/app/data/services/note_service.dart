import 'dart:io';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:get/get.dart';
import 'package:edupulse/app/data/providers/ai_provider.dart';
import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class NoteService extends GetxService {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  final AIProvider _aiProvider = AIProvider();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSummarizing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }
  
 Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      final fetchedNotes = await _supabaseProvider.getNotes();
      // Clear existing notes before adding to prevent duplication
      notes.clear();
      notes.addAll(fetchedNotes);
    } catch (e) {
      print('Error fetching notes: $e');
      // Consider adding error handling for the UI
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<NoteModel?> getNoteById(String id) async {
    try {
      // Check local cache first
      final localNote = notes.firstWhereOrNull((note) => note.id == id);
      if (localNote != null) return localNote;
      
      return await _supabaseProvider.getNoteById(id);
    } catch (e) {
      print('Error getting note by ID: $e');
      return null;
    }
  }

  
  Future<bool> createNote(String title, String content, List<String> tags, {File? file}) async {
    try {
      isLoading.value = true;
      
      String? filePath;
      String? fileUrl;
      String? fileName;
      int fileSize = 0;
      
      if (file != null) {
        fileName = file.path.split('/').last;
        fileUrl = await _supabaseProvider.uploadNoteFile(file, fileName);
        filePath = 'notes/${_authService.currentUser.value!.id}/$fileName';
        fileSize = await file.length();
      }
      
      final newNote = NoteModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser.value!.id,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        filePath: filePath,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
      
      final createdNote = await _supabaseProvider.createNote(newNote);
      
      // Check if note exists locally before adding
      final existingIndex = notes.indexWhere((n) => n.id == createdNote.id);
      if (existingIndex != -1) {
        notes[existingIndex] = createdNote;
      } else {
        notes.add(createdNote);
      }
      
      return true;
    } catch (e) {
      print('Error creating note: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
   Future<bool> updateNote(NoteModel note) async {
    try {
      isLoading.value = true;
      
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _supabaseProvider.updateNote(updatedNote);
      
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = updatedNote;
      } else {
        notes.add(updatedNote);
      }
      
      return true;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> deleteNote(String id) async {
    try {
      isLoading.value = true;
      await _supabaseProvider.deleteNote(id);
      notes.removeWhere((note) => note.id == id);
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<String?> generateSummary(String noteId) async {
    try {
      isSummarizing.value = true;
      
      // Check if user can use AI features
      if (!_authService.canUseAIFeatures) {
        return null;
      }
      
      // Get note
      final note = await getNoteById(noteId);
      if (note == null) return null;
      
      // Generate summary
      final summary = await _aiProvider.summarizeText(note.content);
      
      // Update note with summary
      final updatedNote = note.copyWith(
        summary: summary,
        updatedAt: DateTime.now(),
      );
      
      await _supabaseProvider.updateNote(updatedNote);
      
      // Update local note list
      final index = notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        notes[index] = updatedNote;
        notes.refresh();
      }
      
      // Increment query count
      await _authService.incrementQueryCount();
      
      return summary;
    } catch (e) {
      print('Error generating summary: $e');
      return null;
    } finally {
      isSummarizing.value = false;
    }
  }
  
  Future<List<String>> extractKeyPoints(String noteId) async {
    try {
      // Check if user can use AI features
      if (!_authService.canUseAIFeatures) {
        return [];
      }
      
      // Get note
      final note = await getNoteById(noteId);
      if (note == null) return [];
      
      // Extract key points
      final keyPoints = await _aiProvider.extractKeyPoints(note.content);
      
      // Increment query count
      await _authService.incrementQueryCount();
      
      return keyPoints;
    } catch (e) {
      print('Error extracting key points: $e');
      return [];
    }
  }
}
