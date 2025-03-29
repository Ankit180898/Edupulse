import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConstants {
  // App Info
  static const String appName = 'StudyGenius';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered educational app for enhanced learning';
  
  // API URLs and Keys
  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: 'https://your-supabase-url.supabase.co',
  );
  
  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );
  
  static String get openAIApiKey => const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'your-openai-api-key',
  );
  
  static String get geminiApiKey => const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.example.com';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String langKey = 'app_language';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Feature Flags
  static const bool enableDarkMode = false;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Default Values
  static const int defaultFreeQueryLimit = 5;
  static const int defaultMcqCount = 5;
  static const int defaultFlashcardCount = 5;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Limits
  static const int maxTitleLength = 100;
  static const int maxContentLength = 10000;
  static const int maxFlashcardQuestionLength = 200;
  static const int maxFlashcardAnswerLength = 500;
  static const int maxTagLength = 20;
  static const int maxTagsCount = 5;
  
  // Platform Detection
  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  
  // Support Info
  static const String supportEmail = 'support@edupulse.app';
  static const String privacyPolicyUrl = 'https://edupulse.app/privacy';
  static const String termsOfServiceUrl = 'https://edupulse.app/terms';
  
  // Subscription Plans
  static const double monthlySubscriptionPrice = 199.0;
  static const double quarterlySubscriptionPrice = 499.0;
  static const double yearlySubscriptionPrice = 1499.0;
  
  // Images
  static const String logoPath = 'assets/images/logo.svg';
  static const String placeholderImage = 'assets/images/placeholder.svg';
  
  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'AI-Powered Summarization',
      'description': 'Upload notes and get smart summaries instantly',
      'image': 'assets/images/onboarding1.svg',
    },
    {
      'title': 'Generate MCQs',
      'description': 'Create quizzes to test your knowledge',
      'image': 'assets/images/onboarding2.svg',
    },
    {
      'title': 'Smart Flashcards',
      'description': 'Create and study flashcards effortlessly',
      'image': 'assets/images/onboarding3.svg',
    },
    {
      'title': 'Exam Reminders',
      'description': 'Never miss an important exam again',
      'image': 'assets/images/onboarding4.svg',
    },
  ];
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String authErrorMessage = 'Authentication error. Please sign in again.';
  static const String permissionErrorMessage = 'Permission denied. Please update app permissions.';
}
