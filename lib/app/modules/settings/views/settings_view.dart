import 'package:edupulse/app/modules/settings/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edupulse/app/data/services/settings_service.dart';
import 'package:edupulse/app/core/theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Settings Section
                  _buildSectionHeader('App Settings'),
                  
                  // Theme Settings
                  _buildSettingTile(
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                    trailing: Switch(
                      value: SettingsService().isDarkMode.value,
                      onChanged: controller.toggleDarkMode,
                      activeColor: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Notification Settings
                  _buildSettingTile(
                    title: 'Notifications',
                    subtitle: 'Enable push notifications',
                    trailing: Switch(
                      value: SettingsService().enableNotifications.value,
                      onChanged: SettingsService().enableNotifications.value 
                          ? controller.toggleNotifications 
                          : null,
                      activeColor: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  
                  // Sound Notifications
                  Obx(() => AnimatedOpacity(
                    opacity: SettingsService().enableNotifications.value ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: _buildSettingTile(
                      title: 'Sound Notifications',
                      subtitle: 'Enable sound for notifications',
                      trailing: Switch(
                        value: SettingsService().enableSoundNotifications.value,
                        onChanged: SettingsService().enableNotifications.value 
                            ? controller.toggleSoundNotifications 
                            : null,
                        activeColor: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // AI Settings Section
                  _buildSectionHeader('AI Configuration'),
                  
                  // Google Gemini API Key
                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Google Gemini API Key',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your Google Gemini API key to enable AI features. Without a key, the app will run in demo mode with simulated AI responses.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.apiKeyController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'API Key',
                            hintText: 'Enter your Google Gemini API key',
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureApiKey.value 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                              ),
                              onPressed: controller.toggleApiKeyVisibility,
                            ),
                            enabled: !isLoading,
                          ),
                          obscureText: controller.obscureApiKey.value,
                          validator: controller.validateApiKey,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading ? null : controller.saveApiKey,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.lightTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save API Key'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: isLoading || controller.apiKeyController.text.isEmpty 
                                  ? null 
                                  : controller.clearApiKey,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            controller.isGeminiConfigured
                                ? 'API Key Configured ✓'
                                : 'Running in Demo Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: controller.isGeminiConfigured
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account Section
                  _buildSectionHeader('Account'),
                  
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      onPressed: controller.signOut,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Version
                  Center(
                    child: Text(
                      'EduPulse v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          const Divider(thickness: 1.5),
        ],
      ),
    );
  }
  
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}