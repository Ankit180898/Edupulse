import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/app_bar.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/loading_widget.dart';
import 'package:edupulse/app/modules/subscription/controllers/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Subscription Plans',
        showBackButton: true,
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
              if (controller.hasActiveSubscription) _buildCurrentSubscription() else _buildSubscriptionIntro(),
              const SizedBox(height: 24),
              _buildSubscriptionPlans(),
              const SizedBox(height: 32),
              _buildBenefitsSection(),
              const SizedBox(height: 24),
              _buildFAQSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentSubscription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.subscriptionPlan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.daysRemaining} days remaining',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (controller.isExpiringSoon) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your subscription is expiring soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Renew now to keep enjoying premium features',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.cancelSubscription,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isExpiringSoon ? controller.renewSubscription : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    disabledForegroundColor: Colors.deepPurple.withOpacity(0.5),
                  ),
                  child: const Text('Renew'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(
            Icons.auto_awesome,
            size: 64,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Upgrade Your Study Experience',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free Plan Limitations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'The free plan includes 5 AI queries per day. Upgrade to premium for unlimited features and more AI credits.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Obx(() {
            return ToggleButtons(
              constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
              direction: Axis.horizontal,
              onPressed: controller.selectPlan,
              borderRadius: BorderRadius.circular(8),
              selectedBorderColor: AppColors.primaryColor,
              selectedColor: Colors.white,
              fillColor: AppColors.primaryColor,
              color: AppColors.primaryColor,
              isSelected: List.generate(
                controller.subscriptionPlans.length,
                (index) => index == controller.selectedPlanIndex.value,
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Monthly'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Quarterly'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Yearly'),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 24),
        Obx(() {
          final selectedPlan = controller.subscriptionPlans[controller.selectedPlanIndex.value];

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(Get.context!).shadowColor.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (selectedPlan['bestValue'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange, // Kept orange as an accent color for both themes
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  selectedPlan['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: selectedPlan['price'],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextSpan(
                        text: ' ${selectedPlan['duration']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(Get.context!).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  selectedPlan['features'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green, // Kept green for checkmarks in both themes
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedPlan['features'][index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: controller.hasActiveSubscription ? 'Change Plan' : 'Subscribe Now',
                  onPressed: controller.subscribe,
                  isLoading: controller.processingPayment.value,
                  fullWidth: true,
                  icon: const Icon(Icons.workspace_premium, size: 18),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Subscribe?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          icon: Icons.auto_awesome,
          title: 'Unlimited AI Features',
          description: 'Get unlimited access to AI summarization, MCQ generation, and flashcard creation.',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.speed,
          title: 'Increased Daily Limits',
          description: 'Up to 200 AI queries per day depending on your subscription plan.',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.support_agent,
          title: 'Priority Support',
          description: 'Get help faster with priority customer support.',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildBenefitCard(
          icon: Icons.sync,
          title: 'Future Updates',
          description: 'First access to new features and improvements.',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          question: 'How are subscriptions billed?',
          answer:
              'Subscriptions are billed at the beginning of each period (monthly, quarterly, or yearly) and will automatically renew unless cancelled.',
        ),
        _buildFAQItem(
          question: 'Can I cancel anytime?',
          answer:
              'Yes, you can cancel your subscription at any time. You\'ll continue to have access until the end of your current billing period.',
        ),
        _buildFAQItem(
          question: 'What happens to my data if I cancel?',
          answer:
              'Your data will remain in your account even if you cancel your subscription, but you\'ll be limited to the free plan\'s features and limits.',
        ),
        _buildFAQItem(
          question: 'How do I get a refund?',
          answer: 'Contact our support team at support@aistudyassistant.com for refund requests and assistance.',
        ),
      ],
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
