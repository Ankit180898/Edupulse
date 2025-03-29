import 'package:edupulse/app/data/models/subscription_model.dart';
import 'package:get/get.dart';
import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/data/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class SubscriptionService extends GetxService {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  final AuthService _authService = Get.find<AuthService>();
  
  final Rx<SubscriptionModel?> currentSubscription = Rx<SubscriptionModel?>(null);
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchCurrentSubscription();
  }
  
  Future<void> fetchCurrentSubscription() async {
    try {
      isLoading.value = true;
      
      final subscription = await _supabaseProvider.getCurrentSubscription();
      currentSubscription.value = subscription;
      
      // Check if subscription is expired
      if (subscription != null && subscription.isExpired) {
        await cancelSubscription(subscription.id);
      }
    } catch (e) {
      print('Error fetching subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> subscribeToMonthly() async {
    return await _subscribe(SubscriptionType.monthly, 199.0);
  }
  
  Future<bool> subscribeToQuarterly() async {
    return await _subscribe(SubscriptionType.quarterly, 499.0);
  }
  
  Future<bool> subscribeToYearly() async {
    return await _subscribe(SubscriptionType.yearly, 1499.0);
  }
  
  Future<bool> _subscribe(SubscriptionType type, double price) async {
    try {
      isLoading.value = true;
      
      // TODO: Implement payment processing
      
      // Calculate subscription end date
      final DateTime startDate = DateTime.now();
      DateTime endDate;
      
      switch (type) {
        case SubscriptionType.monthly:
          endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
          break;
        case SubscriptionType.quarterly:
          endDate = DateTime(startDate.year, startDate.month + 3, startDate.day);
          break;
        case SubscriptionType.yearly:
          endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
          break;
        default:
          endDate = startDate; // Free plan doesn't have an end date
      }
      
      // Create new subscription
      final newSubscription = SubscriptionModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser.value!.id,
        type: type,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        price: price,
        paymentMethod: 'Credit Card', // Mock data
      );
      
      await _supabaseProvider.createSubscription(newSubscription);
      currentSubscription.value = newSubscription;
      
      // Update user profile
      final user = _authService.currentUser.value;
      if (user != null) {
        final updatedUser = user.copyWith(
          isSubscribed: true,
          subscriptionExpiry: endDate,
          dailyQueriesLimit: newSubscription.queryLimit,
        );
        
        await _authService.updateUserProfile(updatedUser);
      }
      
      return true;
    } catch (e) {
      print('Error subscribing: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      isLoading.value = true;
      
      await _supabaseProvider.cancelSubscription(subscriptionId);
      
      // Update user profile
      final user = _authService.currentUser.value;
      if (user != null) {
        final updatedUser = user.copyWith(
          isSubscribed: false,
          subscriptionExpiry: null,
          dailyQueriesLimit: 5, // Reset to free tier limit
        );
        
        await _authService.updateUserProfile(updatedUser);
      }
      
      currentSubscription.value = null;
      
      return true;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> renewSubscription() async {
    try {
      isLoading.value = true;
      
      final subscription = currentSubscription.value;
      if (subscription == null) return false;
      
      // Calculate new subscription dates
      final startDate = DateTime.now();
      DateTime endDate;
      
      switch (subscription.type) {
        case SubscriptionType.monthly:
          endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
          break;
        case SubscriptionType.quarterly:
          endDate = DateTime(startDate.year, startDate.month + 3, startDate.day);
          break;
        case SubscriptionType.yearly:
          endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
          break;
        default:
          return false; // Can't renew free plan
      }
      
      // Create new subscription
      final newSubscription = SubscriptionModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser.value!.id,
        type: subscription.type,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        price: subscription.price,
        paymentMethod: subscription.paymentMethod,
      );
      
      await _supabaseProvider.createSubscription(newSubscription);
      currentSubscription.value = newSubscription;
      
      // Update user profile
      final user = _authService.currentUser.value;
      if (user != null) {
        final updatedUser = user.copyWith(
          isSubscribed: true,
          subscriptionExpiry: endDate,
        );
        
        await _authService.updateUserProfile(updatedUser);
      }
      
      return true;
    } catch (e) {
      print('Error renewing subscription: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  bool get hasActiveSubscription {
    return currentSubscription.value != null && 
           currentSubscription.value!.isActive && 
           !currentSubscription.value!.isExpired;
  }
  
  int get daysRemaining {
    if (!hasActiveSubscription) return 0;
    return currentSubscription.value!.daysRemaining;
  }
  
  String get subscriptionPlan {
    if (!hasActiveSubscription) return 'Free Plan';
    return currentSubscription.value!.planName;
  }
}
