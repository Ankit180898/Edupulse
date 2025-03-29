import 'dart:io';

import 'package:edupulse/app/data/models/exam_model.dart';
import 'package:edupulse/app/data/models/flashcard_model.dart';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/data/models/subscription_model.dart';
import 'package:edupulse/app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseProvider {
  // Check if Supabase is initialized
  static bool get isInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Demo mode data
  static final _demoUser = UserModel(
    id: 'demo-user-id',
    email: 'demo@example.com',
    name: 'Demo User',
    photoUrl: 'https://ui-avatars.com/api/?name=Demo+User&background=random',
    createdAt: DateTime.now(),
    isSubscribed: false,
    subscriptionExpiry: null,
    dailyQueriesUsed: 0,
    dailyQueriesLimit: 5,
    lastQueryReset: DateTime.now(),
  );

  static final List<NoteModel> _demoNotes = [];
  static final List<FlashcardModel> _demoFlashcards = [];
  static final List<ExamModel> _demoExams = [];
  static SubscriptionModel? _demoSubscription;

  // Get the Supabase client if available, otherwise work in demo mode
  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (e) {
      print('Supabase client not available, working in demo mode');
      return null;
    }
  }

  // Auth methods
  // Future<AuthResponse?> signInWithGoogle() async {
  //   if (_supabaseClient != null) {
  //     return await _supabaseClient!.auth.signInWithOAuth(
  //       OAuthProvider.google,
  //       redirectTo: 'io.supabase.flutterquickstart://login-callback/',
  //     );
  //   } else {
  //     // Demo mode - pretend we signed in successfully
  //     print('Demo mode: Simulating Google sign-in');
  //     return null;
  //   }
  // }

  Future<AuthResponse?> signInWithEmail(String email, String password) async {
    if (_supabaseClient != null) {
      return await _supabaseClient!.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } else {
      // Demo mode - pretend we signed in successfully
      print('Demo mode: Simulating email sign-in with $email');
      return null;
    }
  }

  Future<AuthResponse?> signUpWithEmail(String email, String password) async {
    if (_supabaseClient != null) {
      return await _supabaseClient!.auth.signUp(
        email: email,
        password: password,
      );
    } else {
      // Demo mode - pretend we signed up successfully
      print('Demo mode: Simulating email sign-up with $email');
      return null;
    }
  }

  Future<void> signOut() async {
    if (_supabaseClient != null) {
      await _supabaseClient!.auth.signOut();
    } else {
      // Demo mode - nothing to do
      print('Demo mode: Simulating sign-out');
    }
  }

  User? get currentUser {
    if (_supabaseClient != null) {
      return _supabaseClient!.auth.currentUser;
    } else {
      // In demo mode, always return a fake user
      return null;
    }
  }

  bool get isAuthenticated {
    if (_supabaseClient != null) {
      return _supabaseClient!.auth.currentUser != null;
    } else {
      // In demo mode, always return true after "signing in"
      return true;
    }
  }

  // User methods
  Future<UserModel?> getUserProfile() async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabaseClient!.from('profiles').select().eq('id', userId).single();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } else {
      // In demo mode, always return the demo user
      print('Demo mode: Returning demo user profile');
      return _demoUser;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('profiles').insert(user.toJson());
    } else {
      print('Demo mode: Simulating create user profile');
      // In demo mode, nothing to do
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('profiles').update(user.toJson()).eq('id', user.id);
    } else {
      print('Demo mode: Simulating update user profile');
      // In demo mode, nothing to do
    }
  }

  // Notes methods
  Future<List<NoteModel>> getNotes() async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return [];

      final response =
          await _supabaseClient!.from('notes').select().eq('user_id', userId).order('created_at', ascending: false);

      return response.map<NoteModel>((json) => NoteModel.fromJson(json)).toList();
    } else {
      print('Demo mode: Returning demo notes');
      return _demoNotes;
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('notes').select().eq('id', noteId).single();

      if (response == null) return null;
      return NoteModel.fromJson(response);
    } else {
      print('Demo mode: Returning demo note by ID');
      return _demoNotes.firstWhere((note) => note.id == noteId, orElse: () => null as NoteModel);
    }
  }

  Future<NoteModel> createNote(NoteModel note) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('notes').insert(note.toJson()).select().single();

      return NoteModel.fromJson(response);
    } else {
      print('Demo mode: Creating demo note');
      final newNote = NoteModel(
        id: const Uuid().v4(),
        userId: _demoUser.id,
        title: note.title,
        content: note.content,
        summary: note.summary,
        tags: note.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _demoNotes.add(newNote);
      return newNote;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('notes').update(note.toJson()).eq('id', note.id);
    } else {
      print('Demo mode: Updating demo note');
      final index = _demoNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _demoNotes[index] = note.copyWith(updatedAt: DateTime.now());
      }
    }
  }
  Future<void> deleteNote(String noteId) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('notes').delete().eq('id', noteId);
    } else {
      print('Demo mode: Deleting demo note');
      _demoNotes.removeWhere((note) => note.id == noteId);
    }
  }

  Future<String> uploadNoteFile(File file, String fileName) async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      final fileExt = fileName.split('.').last;
      final filePath = 'notes/$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final bytes = await file.readAsBytes();
      await _supabaseClient!.storage.from('notes').uploadBinary(filePath, bytes);
      final fileUrl = _supabaseClient!.storage.from('notes').getPublicUrl(filePath);
      return fileUrl;
    } else {
      print('Demo mode: Simulating file upload');
      // In demo mode, return a fake URL
      return 'assets/images/placeholder.svg';
    }
  }

  // Flashcards methods
  Future<List<FlashcardModel>> getFlashcards() async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabaseClient!
          .from('flashcards')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<FlashcardModel>((json) => FlashcardModel.fromJson(json)).toList();
    } else {
      print('Demo mode: Returning demo flashcards');
      return _demoFlashcards;
    }

    // Original code (commented out):
    /*
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map<FlashcardModel>((json) => FlashcardModel.fromJson(json)).toList();
    */
  }

  Future<FlashcardModel?> getFlashcardById(String flashcardId) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('flashcards').select().eq('id', flashcardId).single();

      if (response == null) return null;
      return FlashcardModel.fromJson(response);
    } else {
      print('Demo mode: Returning demo flashcard by ID');
      return _demoFlashcards.firstWhere((flashcard) => flashcard.id == flashcardId,
          orElse: () => null as FlashcardModel);
    }

    // Original code (commented out):
    /*
    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('id', flashcardId)
        .single();

    if (response == null) return null;
    return FlashcardModel.fromJson(response);
    */
  }

  Future<List<FlashcardModel>> getFlashcardsByNoteId(String noteId) async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabaseClient!.from('flashcards').select().eq('user_id', userId).eq('note_id', noteId);

      return response.map<FlashcardModel>((json) => FlashcardModel.fromJson(json)).toList();
    } else {
      print('Demo mode: Returning demo flashcards by note ID');
      return _demoFlashcards.where((flashcard) => flashcard.noteId == noteId).toList();
    }

    // Original code (commented out):
    /*
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('user_id', userId)
        .eq('note_id', noteId);

    return response.map<FlashcardModel>((json) => FlashcardModel.fromJson(json)).toList();
    */
  }

  Future<FlashcardModel> createFlashcard(FlashcardModel flashcard) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('flashcards').insert(flashcard.toJson()).select().single();

      return FlashcardModel.fromJson(response);
    } else {
      print('Demo mode: Creating demo flashcard');
      final newFlashcard = FlashcardModel(
        id: const Uuid().v4(),
        userId: _demoUser.id,
        noteId: flashcard.noteId,
        question: flashcard.question,
        answer: flashcard.answer,
        lastReviewed: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: flashcard.tags,
      );
      _demoFlashcards.add(newFlashcard);
      return newFlashcard;
    }

    // Original code (commented out):
    /*
    final response = await _supabase
        .from('flashcards')
        .insert(flashcard.toJson())
        .select()
        .single();

    return FlashcardModel.fromJson(response);
    */
  }

  Future<void> updateFlashcard(FlashcardModel flashcard) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('flashcards').update(flashcard.toJson()).eq('id', flashcard.id);
    } else {
      print('Demo mode: Updating demo flashcard');
      final index = _demoFlashcards.indexWhere((f) => f.id == flashcard.id);
      if (index != -1) {
        _demoFlashcards[index] = flashcard;
      }
    }

    // Original code (commented out):
    /*
    await _supabase
        .from('flashcards')
        .update(flashcard.toJson())
        .eq('id', flashcard.id);
    */
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('flashcards').delete().eq('id', flashcardId);
    } else {
      print('Demo mode: Deleting demo flashcard');
      _demoFlashcards.removeWhere((flashcard) => flashcard.id == flashcardId);
    }

    // Original code (commented out):
    /*
    await _supabase.from('flashcards').delete().eq('id', flashcardId);
    */
  }

  // Exams methods
  Future<List<ExamModel>> getExams() async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return [];

      final response =
          await _supabaseClient!.from('exams').select().eq('user_id', userId).order('exam_date', ascending: true);

      return response.map<ExamModel>((json) => ExamModel.fromJson(json)).toList();
    } else {
      print('Demo mode: Returning demo exams');
      return _demoExams;
    }

    // Original code (commented out):
    /*
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('exams')
        .select()
        .eq('user_id', userId)
        .order('exam_date', ascending: true);

    return response.map<ExamModel>((json) => ExamModel.fromJson(json)).toList();
    */
  }

  Future<ExamModel?> getExamById(String examId) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('exams').select().eq('id', examId).single();

      if (response == null) return null;
      return ExamModel.fromJson(response);
    } else {
      print('Demo mode: Returning demo exam by ID');
      return _demoExams.firstWhere((exam) => exam.id == examId, orElse: () => null as ExamModel);
    }

    // Original code (commented out):
    /*
    final response = await _supabase
        .from('exams')
        .select()
        .eq('id', examId)
        .single();

    if (response == null) return null;
    return ExamModel.fromJson(response);
    */
  }

  Future<ExamModel> createExam(ExamModel exam) async {
    if (_supabaseClient != null) {
      final response = await _supabaseClient!.from('exams').insert(exam.toJson()).select().single();

      return ExamModel.fromJson(response);
    } else {
      print('Demo mode: Creating demo exam');
      final newExam = ExamModel(
        id: const Uuid().v4(),
        userId: _demoUser.id,
        title: exam.title,
        description: exam.description,
        examDate: exam.examDate,
        examTime: exam.examTime,
        notificationsEnabled: exam.notificationsEnabled,
        reminderTimes: exam.reminderTimes,
        tags: exam.tags,
      );
      _demoExams.add(newExam);
      return newExam;
    }

    // Original code (commented out):
    /*
    final response = await _supabase
        .from('exams')
        .insert(exam.toJson())
        .select()
        .single();

    return ExamModel.fromJson(response);
    */
  }

  Future<void> updateExam(ExamModel exam) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('exams').update(exam.toJson()).eq('id', exam.id);
    } else {
      print('Demo mode: Updating demo exam');
      final index = _demoExams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        _demoExams[index] = exam;
      }
    }

    // Original code (commented out):
    /*
    await _supabase
        .from('exams')
        .update(exam.toJson())
        .eq('id', exam.id);
    */
  }

  Future<void> deleteExam(String examId) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('exams').delete().eq('id', examId);
    } else {
      print('Demo mode: Deleting demo exam');
      _demoExams.removeWhere((exam) => exam.id == examId);
    }

    // Original code (commented out):
    /*
    await _supabase.from('exams').delete().eq('id', examId);
    */
  }

  // Subscription methods
  Future<SubscriptionModel?> getCurrentSubscription() async {
    if (_supabaseClient != null) {
      final userId = _supabaseClient!.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabaseClient!
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('end_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return SubscriptionModel.fromJson(response);
    } else {
      print('Demo mode: Returning demo subscription');
      // In demo mode, create a default free tier subscription
      _demoSubscription ??= SubscriptionModel(
        id: const Uuid().v4(),
        userId: _demoUser.id,
        type: SubscriptionType.free,
        price: 0,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      );
      return _demoSubscription;
    }

    // Original code (commented out):
    /*
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('end_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SubscriptionModel.fromJson(response);
    */
  }

  Future<void> createSubscription(SubscriptionModel subscription) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('subscriptions').insert(subscription.toJson());
    } else {
      print('Demo mode: Creating demo subscription');
      _demoSubscription = subscription.copyWith(
        id: const Uuid().v4(),
        userId: _demoUser.id,
        startDate: DateTime.now(),
      );
    }
    /*
    await _supabase.from('subscriptions').insert(subscription.toJson());
    */
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('subscriptions').update(subscription.toJson()).eq('id', subscription.id);
    } else {
      print('Demo mode: Updating demo subscription');
      if (_demoSubscription != null && _demoSubscription!.id == subscription.id) {
        _demoSubscription = subscription;
      }
    }

    // Original code (commented out):
    /*
    await _supabase
        .from('subscriptions')
        .update(subscription.toJson())
        .eq('id', subscription.id);
    */
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    if (_supabaseClient != null) {
      await _supabaseClient!.from('subscriptions').update({'is_active': false}).eq('id', subscriptionId);
    } else {
      print('Demo mode: Cancelling demo subscription');
      if (_demoSubscription != null && _demoSubscription!.id == subscriptionId) {
        _demoSubscription = _demoSubscription!.copyWith(isActive: false);
      }
    }

    // Original code (commented out):
    /*
    await _supabase
        .from('subscriptions')
        .update({'is_active': false})
        .eq('id', subscriptionId);
    */
  }

  // Helper method to use demo data in various AI features
  Future<bool> checkAndDecrementAICredits() async {
    if (_supabaseClient != null) {
      final subscription = await getCurrentSubscription();
      if (subscription == null) return false;

      if (subscription.aiCreditsUsed >= subscription.aiCreditsTotal) {
        return false; // No credits left
      }

      // Decrement credits
      await updateSubscription(subscription.copyWith(aiCreditsUsed: subscription.aiCreditsUsed + 1));
      return true;
    } else {
      // In demo mode, simulate credit usage
      if (_demoSubscription == null) {
        await getCurrentSubscription(); // Ensure demo subscription exists
      }

      if (_demoSubscription!.aiCreditsUsed >= _demoSubscription!.aiCreditsTotal) {
        return false; // No credits left
      }

      // Decrement credits
      _demoSubscription = _demoSubscription!.copyWith(aiCreditsUsed: _demoSubscription!.aiCreditsUsed + 1);
      return true;
    }
  }
}
