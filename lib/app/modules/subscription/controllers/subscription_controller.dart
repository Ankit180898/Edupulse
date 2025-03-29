import 'package:edupulse/app/core/utils/helpers.dart';
import 'package:edupulse/app/data/models/subscription_model.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:edupulse/app/data/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SubscriptionController extends GetxController {
  final SubscriptionService _subscriptionService = Get.find<SubscriptionService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isLoading = false.obs;
  final RxInt selectedPlanIndex = 0.obs;
  final RxBool processingPayment = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }
  
  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;
      await _subscriptionService.fetchCurrentSubscription();
    } catch (e) {
      print('Error fetching subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }
  
  Future<bool> subscribe() async {
    try {
      processingPayment.value = true;
      
      bool success = false;
      
      switch (selectedPlanIndex.value) {
        case 0: // Monthly
          success = await _subscriptionService.subscribeToMonthly();
          break;
        case 1: // Quarterly
          success = await _subscriptionService.subscribeToQuarterly();
          break;
        case 2: // Yearly
          success = await _subscriptionService.subscribeToYearly();
          break;
      }
      
      if (success) {
        showSuccessSnackbar('Success', 'Successfully subscribed to ${getSelectedPlanName()}');
        return true;
      } else {
        showErrorSnackbar('Error', 'Failed to process subscription');
        return false;
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error subscribing: ${e.toString()}');
      return false;
    } finally {
      processingPayment.value = false;
    }
  }
  
  Future<bool> renewSubscription() async {
    try {
      processingPayment.value = true;
      
      final success = await _subscriptionService.renewSubscription();
      
      if (success) {
        showSuccessSnackbar('Success', 'Successfully renewed your subscription');
        return true;
      } else {
        showErrorSnackbar('Error', 'Failed to renew subscription');
        return false;
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error renewing subscription: ${e.toString()}');
      return false;
    } finally {
      processingPayment.value = false;
    }
  }
  
  Future<bool> cancelSubscription() async {
    try {
      isLoading.value = true;
      
      final currentSubscription = _subscriptionService.currentSubscription.value;
      if (currentSubscription == null) return false;
      
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Subscription'),
          content: const Text(
            'Are you sure you want to cancel your subscription? '
            'You will still have access until the end of your current billing period.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No, Keep My Plan'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return false;
      
      final success = await _subscriptionService.cancelSubscription(currentSubscription.id);
      
      if (success) {
        showSuccessSnackbar('Success', 'Your subscription has been cancelled');
        return true;
      } else {
        showErrorSnackbar('Error', 'Failed to cancel subscription');
        return false;
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Error cancelling subscription: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  List<Map<String, dynamic>> get subscriptionPlans => [
    {
      'name': 'Monthly',
      'price': '₹199',
      'duration': 'per month',
      'features': [
        'Unlimited AI summarization',
        'Unlimited MCQ generation',
        'Unlimited flashcards',
        '50 AI queries per day',
        'Priority support',
      ],
      'bestValue': false,
    },
    {
      'name': 'Quarterly',
      'price': '₹499',
      'duration': 'per 3 months',
      'features': [
        'All monthly features',
        '100 AI queries per day',
        'Save ₹98 (16%)',
        'Export notes & cards',
        'Advanced statistics',
      ],
      'bestValue': true,
    },
    {
      'name': 'Yearly',
      'price': '₹1499',
      'duration': 'per year',
      'features': [
        'All quarterly features',
        '200 AI queries per day',
        'Save ₹889 (37%)',
        'Offline access',
        'Premium support',
      ],
      'bestValue': false,
    },
  ];
  
  String getSelectedPlanName() {
    return subscriptionPlans[selectedPlanIndex.value]['name'];
  }
  
  bool get hasActiveSubscription => _subscriptionService.hasActiveSubscription;
  
  SubscriptionModel? get currentSubscription => _subscriptionService.currentSubscription.value;
  
  int get daysRemaining => _subscriptionService.daysRemaining;
  
  String get subscriptionPlan => _subscriptionService.subscriptionPlan;
  
  bool get isExpiringSoon => hasActiveSubscription && daysRemaining <= 7;
  
  bool get isExpired => currentSubscription != null && currentSubscription!.isExpired;
}
