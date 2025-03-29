import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  
  final RxBool isSignUp = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
  
  void toggleSignUp() {
    isSignUp.value = !isSignUp.value;
    // Clear fields when switching modes
    if (!isSignUp.value) {
      nameController.clear();
    }
  }
  
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  Future<void> handleGoogleSignIn() async {
    try {
      isLoading.value = true;
      final success = await _authService.signInWithGoogle();
      
      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        showErrorSnackbar('Google Sign In Failed', 'Please try again later.');
      }
    } catch (e) {
      showErrorSnackbar('Google Sign In Failed', 'Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> handleEmailAuth() async {
    if (!validateForm()) return;
    
    try {
      isLoading.value = true;
      bool success;
      
      if (isSignUp.value) {
        success = await _authService.signUpWithEmail(
          emailController.text,
          passwordController.text,
          nameController.text,
        );
      } else {
        success = await _authService.signInWithEmail(
          emailController.text,
          passwordController.text,
        );
      }
      
      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        showErrorSnackbar(
          isSignUp.value ? 'Sign Up Failed' : 'Sign In Failed',
          'Please check your credentials and try again.'
        );
      }
    } catch (e) {
      showErrorSnackbar(
        isSignUp.value ? 'Sign Up Failed' : 'Sign In Failed',
        'Error: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  bool validateForm() {
    // Email validation
    if (emailController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Email is required');
      return false;
    }
    
    if (!GetUtils.isEmail(emailController.text)) {
      showErrorSnackbar('Validation Error', 'Please enter a valid email');
      return false;
    }
    
    // Password validation
    if (passwordController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Password is required');
      return false;
    }
    
    if (isSignUp.value && passwordController.text.length < 6) {
      showErrorSnackbar('Validation Error', 'Password must be at least 6 characters');
      return false;
    }
    
    // Name validation (only for sign up)
    if (isSignUp.value && nameController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Name is required');
      return false;
    }
    
    return true;
  }
}
