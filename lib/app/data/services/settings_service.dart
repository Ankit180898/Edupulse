import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SettingsService extends GetxService {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final RxBool isLoading = false.obs;

  // API Keys
  final RxString geminiApiKey = ''.obs;

  // Theme settings
  final RxBool isDarkMode = false.obs;

  // Notification settings
  final RxBool enableNotifications = true.obs;
  final RxBool enableSoundNotifications = true.obs;

  Future<SettingsService> init() async {
    try {
      isLoading.value = true;

      // Load API keys
      final savedGeminiKey = await _secureStorage.read(key: 'gemini_api_key');
      if (savedGeminiKey != null && savedGeminiKey.isNotEmpty) {
        geminiApiKey.value = savedGeminiKey;
      }

      // Load theme settings
      final savedTheme = await _secureStorage.read(key: 'dark_mode');
      if (savedTheme != null) {
        isDarkMode.value = savedTheme == 'true';
      }

      // Load notification settings
      final savedNotifications = await _secureStorage.read(key: 'enable_notifications');
      if (savedNotifications != null) {
        enableNotifications.value = savedNotifications == 'true';
      }

      final savedSoundNotifications = await _secureStorage.read(key: 'enable_sound_notifications');
      if (savedSoundNotifications != null) {
        enableSoundNotifications.value = savedSoundNotifications == 'true';
      }

      return this;
    } catch (e) {
      print('Error initializing settings: $e');
      return this;
    } finally {
      isLoading.value = false;
    }
  }

  // Save Gemini API key
  Future<bool> saveGeminiApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: 'gemini_api_key', value: apiKey);
      geminiApiKey.value = apiKey;
      return true;
    } catch (e) {
      print('Error saving Gemini API key: $e');
      return false;
    }
  }

  // Clear Gemini API key
  Future<bool> clearGeminiApiKey() async {
    try {
      await _secureStorage.delete(key: 'gemini_api_key');
      geminiApiKey.value = '';
      return true;
    } catch (e) {
      print('Error clearing Gemini API key: $e');
      return false;
    }
  }

  // Save theme settings
  Future<bool> saveThemeSettings(bool isDark) async {
    try {
      await _secureStorage.write(key: 'dark_mode', value: isDark.toString());
      isDarkMode.value = isDark;
      return true;
    } catch (e) {
      print('Error saving theme settings: $e');
      return false;
    }
  }

  // Save notification settings
  Future<bool> saveNotificationSettings({
    bool? enableNotifs,
    bool? enableSoundNotifs,
  }) async {
    try {
      if (enableNotifs != null) {
        await _secureStorage.write(key: 'enable_notifications', value: enableNotifs.toString());
        enableNotifications.value = enableNotifs;
      }

      if (enableSoundNotifs != null) {
        await _secureStorage.write(key: 'enable_sound_notifications', value: enableSoundNotifs.toString());
        enableSoundNotifications.value = enableSoundNotifs;
      }

      return true;
    } catch (e) {
      print('Error saving notification settings: $e');
      return false;
    }
  }

  // Check if Gemini API is configured
  bool get isGeminiConfigured => geminiApiKey.value.isNotEmpty;
}
