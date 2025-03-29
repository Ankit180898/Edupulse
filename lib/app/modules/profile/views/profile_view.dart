import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/custom_text_field.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: true,
        actions: [
          Obx(() {
            return IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.close : Icons.edit,
              ),
              onPressed: controller.toggleEditMode,
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileForm(),
              const SizedBox(height: 24),
              _buildSubscriptionCard(),
              const SizedBox(height: 24),
              _buildUsageStats(),
              const SizedBox(height:32),
              _buildButtons(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          Text(
            controller.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.email,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: controller.photoUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: CachedNetworkImage(
                    imageUrl: controller.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
        ),
        if (controller.isSubscribed)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.nameController,
          labelText: 'Name',
          hintText: 'Enter your name',
          prefixIcon: Icons.person,
          enabled: controller.isEditing.value,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icons.email,
          enabled: false, // Email can't be changed
        ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.isEditing.value) {
            return CustomButton(
              text: 'Save Changes',
              onPressed: controller.updateProfile,
              isLoading: controller.isLoading.value,
              fullWidth: true,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isSubscribed ? Colors.deepPurple : Colors.orange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.isSubscribed ? Icons.workspace_premium : Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.subscriptionPlan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (controller.isSubscribed) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${controller.daysRemaining} days remaining',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.navigateToSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: controller.isSubscribed ? Colors.deepPurple : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  controller.isSubscribed ? 'Manage' : 'Upgrade',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Features:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureRow('AI-powered summarization', true),
          _buildFeatureRow('MCQ generation from notes', true),
          _buildFeatureRow('Unlimited flashcards', true),
          _buildFeatureRow(
            'Unlimited AI queries',
            controller.isSubscribed,
          ),
          if (!controller.isSubscribed) ...[
            const SizedBox(height: 8),
            Text(
              '${controller.remainingQueries} free AI queries left today',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.radio_button_unchecked,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isAvailable ? FontWeight.normal : FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usage Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow('AI Credits Used Today', '${controller.user?.dailyQueriesUsed ?? 0}'),
              const Divider(),
              _buildStatRow('AI Credit Limit', '${controller.user?.dailyQueriesLimit ?? 5}'),
              const Divider(),
              _buildStatRow('Account Created', _formatDate(controller.user?.createdAt)),
              if (controller.isSubscribed) ...[
                const Divider(),
                _buildStatRow('Subscription Expires', _formatDate(controller.user?.subscriptionExpiry)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: controller.showConfirmSignOutDialog,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
