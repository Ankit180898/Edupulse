import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';
import 'package:edupulse/app/core/widgets/custom_text_field.dart';
import 'package:edupulse/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildSocialLogin(),
                  const SizedBox(height: 20),
                  _buildToggleButtons(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            size: 50,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AI Study Assistant',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          controller.isSignUp.value 
              ? 'Create a new account to get started'
              : 'Log in to access your study materials',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.isSignUp.value) ...[
          CustomTextField(
            controller: controller.nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
        ],
        CustomTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock,
          obscureText: controller.obscurePassword.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.handleEmailAuth(),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.secondaryTextColor,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
        if (!controller.isSignUp.value) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        CustomButton(
          text: controller.isSignUp.value ? 'Sign Up' : 'Log In',
          onPressed: controller.handleEmailAuth,
          isLoading: controller.isLoading.value,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade400,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade400,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: '${controller.isSignUp.value ? 'Sign Up' : 'Log In'} with Google',
          onPressed: controller.handleGoogleSignIn,
          isLoading: controller.isLoading.value,
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey.shade300,
          icon: const FaIcon(
            FontAwesomeIcons.google,
            color: Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.isSignUp.value
              ? 'Already have an account?'
              : 'Don\'t have an account?',
          style: TextStyle(
            color: AppColors.secondaryTextColor,
          ),
        ),
        TextButton(
          onPressed: controller.toggleSignUp,
          child: Text(
            controller.isSignUp.value ? 'Log In' : 'Sign Up',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
