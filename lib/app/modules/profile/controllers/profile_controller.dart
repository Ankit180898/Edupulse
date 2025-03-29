import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/models/user_model.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SubscriptionService _subscriptionService = Get.find<SubscriptionService>();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
  
  void _loadUserData() {
    final user = _authService.currentUser.value;
    if (user != null) {
      nameController.text = user.name ?? '';
      emailController.text = user.email;
    }
  }
  
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset fields when cancelling edit
      _loadUserData();
    }
  }
  
  Future<void> updateProfile() async {
    if (nameController.text.isEmpty) {
      showErrorSnackbar('Validation Error', 'Name is required');
      return;
    }
    
    try {
      isLoading.value = true;
      
      final user = _authService.currentUser.value;
      if (user != null) {
        final updatedUser = user.copyWith(
          name: nameController.text,
        );
        
        final success = await _authService.updateUserProfile(updatedUser);
        
        if (success) {
          isEditing.value = false;
          showSuccessSnackbar('Success', 'Profile updated successfully');
        } else {
          showErrorSnackbar('Error', 'Failed to update profile');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error updating profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
    } catch (e) {
      showErrorSnackbar('Error', 'Error signing out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToSubscription() {
    Get.toNamed('/subscription');
  }
  
  UserModel? get user => _authService.currentUser.value;
  
  String get name => user?.name ?? 'User';
  
  String get email => user?.email ?? '';
  
  String get photoUrl => user?.photoUrl ?? '';
  
  bool get isSubscribed => user?.isSubscribed ?? false;
  
  String get subscriptionPlan => _subscriptionService.subscriptionPlan;
  
  int get remainingQueries => _authService.remainingQueries;
  
  int get daysRemaining => _subscriptionService.daysRemaining;
  
  void showConfirmSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
