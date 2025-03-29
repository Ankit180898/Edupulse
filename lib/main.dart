import 'package:edupulse/app/app.dart';
import 'package:edupulse/app/core/values/app_constants.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
        Get.put(AuthService(), permanent: true);

  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize Supabase (if keys are available)
  try {
    if (AppConstants.supabaseUrl != 'https://your-supabase-url.supabase.co' && 
        AppConstants.supabaseAnonKey != 'your-supabase-anon-key') {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      print('Supabase initialized successfully');
    } else {
      print('Supabase not initialized: Using demo mode without backend');
    }
  } catch (e) {
    print('Error initializing Supabase: $e');
    print('Running in demo mode without backend');
  }

  // Initialize notifications
  await NotificationService.initialize();
  
  runApp(const App());
}
