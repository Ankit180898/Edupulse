import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edupulse/app/data/services/settings_service.dart';
import 'package:edupulse/app/data/services/auth_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final formKey = GlobalKey<FormState>();
  final apiKeyController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscureApiKey = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize text controllers with current values
    apiKeyController.text = _settingsService.geminiApiKey.value;
    
    // Listen to changes in the settings service
    ever(_settingsService.geminiApiKey, (apiKey) {
      apiKeyController.text = apiKey;
    });
  }
  
  @override
  void onClose() {
    apiKeyController.dispose();
    super.onClose();
  }
  
  // Toggle dark mode
  void toggleDarkMode(bool value) {
    _settingsService.saveThemeSettings(value);
  }
  
  // Toggle notifications
  void toggleNotifications(bool value) {
    _settingsService.saveNotificationSettings(enableNotifs: value);
  }
  
  // Toggle sound notifications
  void toggleSoundNotifications(bool value) {
    _settingsService.saveNotificationSettings(enableSoundNotifs: value);
  }
  
  // Toggle API key visibility
  void toggleApiKeyVisibility() {
    obscureApiKey.value = !obscureApiKey.value;
  }
  
  // Save API key
  Future<bool> saveApiKey() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    isLoading.value = true;
    try {
      final result = await _settingsService.saveGeminiApiKey(apiKeyController.text.trim());
      if (result) {
        Get.snackbar(
          'Success', 
          'API key saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error', 
          'Failed to save API key',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return result;
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear API key
  Future<bool> clearApiKey() async {
    isLoading.value = true;
    try {
      final result = await _settingsService.clearGeminiApiKey();
      if (result) {
        apiKeyController.clear();
        Get.snackbar(
          'Success', 
          'API key cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error', 
          'Failed to clear API key',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return result;
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to sign out: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Validate API key
  String? validateApiKey(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for now (will use demo mode)
    }
    
    if (value.length < 10) {
      return 'API key seems too short';
    }
    
    return null;
  }
  
  // Check if Gemini API is configured
  bool get isGeminiConfigured => _settingsService.isGeminiConfigured;
}