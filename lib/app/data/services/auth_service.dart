import 'package:edupulse/app/data/models/user_model.dart';
import 'package:edupulse/app/data/providers/supabase_provider.dart';
import 'package:edupulse/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService extends GetxService {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _handleAuthStateChange();
  }

  Future<void> _handleAuthStateChange() async {
    try {
      // Only register listener if Supabase is initialized
      if (SupabaseProvider.isInitialized) {
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
          final AuthChangeEvent event = data.event;
          
          if (event == AuthChangeEvent.signedIn) {
            isLoading.value = true;
            await _loadUserProfile();
            isLoading.value = false;
            
            Get.offAllNamed(Routes.HOME);
          } else if (event == AuthChangeEvent.signedOut) {
            currentUser.value = null;
            Get.offAllNamed(Routes.LOGIN);
          }
        });
      } else {
        // In demo mode, we'll automatically log in without going through authentication
        print('Demo mode: Auto-logging in without authentication');
        isLoading.value = true;
        await _loadUserProfile();
        isLoading.value = false;
        
        // Wait a moment before navigating to allow app to initialize properly
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
      }

      // Check if user is already signed in (for real Supabase mode)
      if (_supabaseProvider.currentUser != null) {
        isLoading.value = true;
        await _loadUserProfile();
        isLoading.value = false;
      }
    } catch (e) {
      print('Error in auth state change handling: $e');
      // For demo mode, still try to load a user profile
      if (!SupabaseProvider.isInitialized) {
        await _loadUserProfile();
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      // Demo mode check - if Supabase is not initialized, create a demo user
      if (!SupabaseProvider.isInitialized) {
        print('Demo mode: Creating demo user profile');
        // Create a demo user with default values
        final demoUser = UserModel(
          id: 'demo-user-id',
          email: 'demo@example.com',
          name: 'Demo User',
          photoUrl: 'https://ui-avatars.com/api/?name=Demo+User&background=random',
          createdAt: DateTime.now(),
          isSubscribed: false,
          dailyQueriesUsed: 0,
          dailyQueriesLimit: 5,  // Default free tier limit
          lastQueryReset: DateTime.now(),
        );
        
        currentUser.value = demoUser;
        return;
      }
      
      // Original code for Supabase mode:
      final userProfile = await _supabaseProvider.getUserProfile();
      
      if (userProfile != null) {
        // Check if daily query limit needs to be reset
        if (userProfile.shouldResetDailyQueries) {
          final updatedUser = userProfile.copyWith(
            dailyQueriesUsed: 0,
            lastQueryReset: DateTime.now(),
          );
          
          await _supabaseProvider.updateUserProfile(updatedUser);
          currentUser.value = updatedUser;
        } else {
          currentUser.value = userProfile;
        }
      } else if (_supabaseProvider.currentUser != null) {
        // Create new user profile if it doesn't exist
        final newUser = UserModel(
          id: _supabaseProvider.currentUser!.id,
          email: _supabaseProvider.currentUser!.email ?? '',
          name: _supabaseProvider.currentUser!.userMetadata?['full_name'],
          photoUrl: _supabaseProvider.currentUser!.userMetadata?['avatar_url'],
          createdAt: DateTime.now(),
          isSubscribed: false,
          dailyQueriesUsed: 0,
          dailyQueriesLimit: 5,  // Default free tier limit
          lastQueryReset: DateTime.now(),
        );
        
        await _supabaseProvider.createUserProfile(newUser);
        currentUser.value = newUser;
      }
    } catch (e) {
      print('Error loading user profile: $e');
      
      // Fallback to demo mode on error if Supabase is not initialized
      if (!SupabaseProvider.isInitialized && currentUser.value == null) {
        print('Falling back to demo mode after error');
        currentUser.value = UserModel(
          id: 'demo-user-id',
          email: 'demo@example.com',
          name: 'Demo User',
          photoUrl: 'https://ui-avatars.com/api/?name=Demo+User&background=random',
          createdAt: DateTime.now(),
          isSubscribed: false,
          dailyQueriesUsed: 0,
          dailyQueriesLimit: 5,
          lastQueryReset: DateTime.now(),
        );
      }
    }
  }

  Future<bool> signInWithGoogle() async {
    // Check if we're in demo mode
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Simulating Google sign in');
      isLoading.value = true;
      
      // Simulate a successful login in demo mode
      await _loadUserProfile(); // This will create a demo user
      isLoading.value = false;
      
      // Navigate to home screen
      Get.offAllNamed(Routes.HOME);
      return true;
    }

    // Original code for when Supabase is available:
    try {
      isLoading.value = true;
      
      // Start Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return false;
      }
      
      // Get auth details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Use Google credentials with Supabase
      final AuthResponse res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (res.user != null) {
        await _loadUserProfile();
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    // Check if we're in demo mode
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Simulating email sign in with $email');
      isLoading.value = true;
      
      // Simulate a successful login in demo mode
      await _loadUserProfile(); // This will create a demo user
      isLoading.value = false;
      
      // Navigate to home screen
      Get.offAllNamed(Routes.HOME);
      return true;
    }

    // Original code for when Supabase is available:
    try {
      isLoading.value = true;
      
      final res = await _supabaseProvider.signInWithEmail(email, password);
      
      if (res?.user != null) {
        await _loadUserProfile();
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error signing in with email: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    // Check if we're in demo mode
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Simulating email sign up for $email/$name');
      isLoading.value = true;
      
      // Create a demo user with the provided email and name
      final demoUser = UserModel(
        id: 'demo-user-id',
        email: email,
        name: name,
        photoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        createdAt: DateTime.now(),
        isSubscribed: false,
        dailyQueriesUsed: 0,
        dailyQueriesLimit: 5,  // Default free tier limit
        lastQueryReset: DateTime.now(),
      );
      
      currentUser.value = demoUser;
      isLoading.value = false;
      
      // Navigate to home screen
      Get.offAllNamed(Routes.HOME);
      return true;
    }

    // Original code for when Supabase is available:
    try {
      isLoading.value = true;
      
      final res = await _supabaseProvider.signUpWithEmail(email, password);
      
      if (res?.user != null) {
        final newUser = UserModel(
          id: res!.user!.id,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          isSubscribed: false,
          dailyQueriesUsed: 0,
          dailyQueriesLimit: 5,  // Default free tier limit
          lastQueryReset: DateTime.now(),
        );
        
        await _supabaseProvider.createUserProfile(newUser);
        currentUser.value = newUser;
        
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error signing up with email: $e');
      isLoading.value = false;
      return false;
    }
  }

  Future<void> signOut() async {
    // Demo mode handling
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Simulating sign out');
      currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    
    // Original code for when Supabase is available:
    try {
      await _googleSignIn.signOut();
      await _supabaseProvider.signOut();
      currentUser.value = null;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> updateUserProfile(UserModel user) async {
    // Demo mode handling
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Updating user profile locally');
      currentUser.value = user;
      return true;
    }
    
    // Original code for when Supabase is available:
    try {
      await _supabaseProvider.updateUserProfile(user);
      currentUser.value = user;
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> incrementQueryCount() async {
    if (currentUser.value == null) return false;
    
    // Demo mode handling - maintain query count locally 
    if (!SupabaseProvider.isInitialized) {
      print('Demo mode: Incrementing query count locally');
      
      // Check if user has reached their query limit
      if (currentUser.value!.hasReachedQueryLimit && !currentUser.value!.isSubscribed) {
        return false;
      }
      
      // Update the local user object
      currentUser.value = currentUser.value!.copyWith(
        dailyQueriesUsed: currentUser.value!.dailyQueriesUsed + 1,
      );
      
      return true;
    }
    
    // Original code for when Supabase is available:
    try {
      // Check if user has reached their query limit
      if (currentUser.value!.hasReachedQueryLimit && !currentUser.value!.isSubscribed) {
        return false;
      }
      
      final updatedUser = currentUser.value!.copyWith(
        dailyQueriesUsed: currentUser.value!.dailyQueriesUsed + 1,
      );
      
      await _supabaseProvider.updateUserProfile(updatedUser);
      currentUser.value = updatedUser;
      return true;
    } catch (e) {
      print('Error incrementing query count: $e');
      return false;
    }
  }

  bool get canUseAIFeatures {
    if (currentUser.value == null) return false;
    if (currentUser.value!.isSubscribed) return true;
    return !currentUser.value!.hasReachedQueryLimit;
  }

  int get remainingQueries {
    if (currentUser.value == null) return 0;
    return currentUser.value!.dailyQueriesLimit - currentUser.value!.dailyQueriesUsed;
  }
}
