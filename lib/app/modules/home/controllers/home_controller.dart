import 'package:edupulse/app/data/models/exam_model.dart';
import 'package:edupulse/app/data/models/flashcard_model.dart';
import 'package:edupulse/app/data/models/note_model.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/exam_service.dart';
import 'package:edupulse/app/data/services/flashcard_service.dart';
import 'package:edupulse/app/data/services/note_service.dart';
import 'package:edupulse/app/data/services/subscription_service.dart';
import 'package:get/get.dart';


class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final NoteService _noteService = Get.put(NoteService());
  final FlashcardService _flashcardService = Get.put(FlashcardService());
  final ExamService _examService = Get.put(ExamService());
  final SubscriptionService _subscriptionService = Get.put(SubscriptionService());
  
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }
  
  Future<void> _loadData() async {
    isLoading.value = true;
    
    await Future.wait([
      _noteService.fetchNotes(),
      _flashcardService.fetchFlashcards(),
      _examService.fetchExams(),
      _subscriptionService.fetchCurrentSubscription(),
    ]);
    
    isLoading.value = false;
  }
  
  Future<void> refreshData() async {
    await _loadData();
  }
  
  String get username => _authService.currentUser.value?.name ?? 'Student';
  
  String get profileImage => _authService.currentUser.value?.photoUrl ?? '';
  
  bool get isSubscribed => _authService.currentUser.value?.isSubscribed ?? false;
  
  int get remainingQueries => _authService.remainingQueries;
  
  List<NoteModel> get recentNotes {
    return _noteService.notes.take(5).toList();
  }
  
  List<FlashcardModel> get flashcardsForReview {
    return _flashcardService.getFlashcardsForReview().take(5).toList();
  }
  
  List<ExamModel> get upcomingExams {
    return _examService.getUpcomingExams().take(3).toList();
  }
  
  String get subscriptionPlan => _subscriptionService.subscriptionPlan;
  
  int get daysRemaining => _subscriptionService.daysRemaining;
  
  int get totalNotes => _noteService.notes.length;
  
  int get totalFlashcards => _flashcardService.flashcards.length;
  
  int get totalExams => _examService.exams.length;
  
  int get flashcardsToReview => _flashcardService.getFlashcardsForReview().length;
  
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
