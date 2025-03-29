import 'package:edupulse/app/data/services/settings_service.dart';
import 'package:edupulse/app/modules/auth/controllers/auth_controller.dart';
import 'package:edupulse/app/modules/auth/views/login_view.dart';
import 'package:edupulse/app/modules/exams/controllers/exams_controller.dart';
import 'package:edupulse/app/modules/exams/views/exam_add_view.dart';
import 'package:edupulse/app/modules/exams/views/exams_view.dart';
import 'package:edupulse/app/modules/flashcards/controllers/flashcards_controller.dart';
import 'package:edupulse/app/modules/flashcards/views/flashcard_add_view.dart';
import 'package:edupulse/app/modules/flashcards/views/flashcard_detail_view.dart';
import 'package:edupulse/app/modules/flashcards/views/flashcards_view.dart';
import 'package:edupulse/app/modules/home/controllers/home_controller.dart';
import 'package:edupulse/app/modules/home/views/home_view.dart';
import 'package:edupulse/app/modules/mcq/controllers/mcq_controller.dart';
import 'package:edupulse/app/modules/mcq/views/mcq_generate_view.dart';
import 'package:edupulse/app/modules/mcq/views/mcq_view.dart';
import 'package:edupulse/app/modules/notes/controllers/notes_controller.dart';
import 'package:edupulse/app/modules/notes/views/note_add_view.dart';
import 'package:edupulse/app/modules/notes/views/note_detail_view.dart';
import 'package:edupulse/app/modules/notes/views/notes_view.dart';
import 'package:edupulse/app/modules/notes/views/summary_view.dart';
import 'package:edupulse/app/modules/profile/controllers/profile_controller.dart';
import 'package:edupulse/app/modules/profile/views/profile_view.dart';
import 'package:edupulse/app/modules/settings/controller/settings_controller.dart';
import 'package:edupulse/app/modules/settings/views/settings_view.dart';
import 'package:edupulse/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:edupulse/app/modules/subscription/views/subscription_view.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsService>(() => SettingsService());

        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.NOTES,
      page: () => const NotesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotesController>(() => NotesController());
      }),
    ),
    GetPage(
      name: Routes.NOTE_DETAIL,
      page: () => const NoteDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotesController>(() => NotesController());
      }),
    ),
    GetPage(
      name: Routes.NOTE_ADD,
      page: () => const NoteAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotesController>(() => NotesController());
      }),
    ),
    GetPage(
      name: Routes.SUMMARY,
      page: () => const SummaryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotesController>(() => NotesController());
      }),
    ),
    GetPage(
      name: Routes.MCQ,
      page: () => const McqView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<McqController>(() => McqController());
      }),
    ),
    GetPage(
      name: Routes.MCQ_GENERATE,
      page: () => const McqGenerateView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<McqController>(() => McqController());
      }),
    ),
    GetPage(
      name: Routes.FLASHCARDS,
      page: () => const FlashcardsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FlashcardsController>(() => FlashcardsController());
      }),
    ),
    GetPage(
      name: Routes.FLASHCARD_DETAIL,
      page: () => const FlashcardDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FlashcardsController>(() => FlashcardsController());
      }),
    ),
    GetPage(
      name: Routes.FLASHCARD_ADD,
      page: () => const FlashcardAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FlashcardsController>(() => FlashcardsController());
      }),
    ),
    GetPage(
      name: Routes.EXAMS,
      page: () => const ExamsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ExamsController>(() => ExamsController());
      }),
    ),
    GetPage(
      name: Routes.EXAM_ADD,
      page: () => const ExamAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ExamsController>(() => ExamsController());
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
        Get.lazyPut<SettingsService>(() => SettingsService());
      }),
    ),
  ];
}
