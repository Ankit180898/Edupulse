import 'package:flutter/material.dart';
import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:edupulse/app/core/widgets/custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;
  final bool showButton;

  const ErrorDisplayWidget({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'Try Again',
    this.onButtonPressed,
    this.icon = Icons.error_outline,
    this.showButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.errorColor,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                backgroundColor: AppColors.errorColor,
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Common error widget factory methods
  factory ErrorDisplayWidget.network({VoidCallback? onRetry}) {
    return ErrorDisplayWidget(
      title: 'Network Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
      icon: Icons.wifi_off,
    );
  }

  factory ErrorDisplayWidget.server({VoidCallback? onRetry}) {
    return ErrorDisplayWidget(
      title: 'Server Error',
      message: 'Something went wrong on our servers. Please try again later.',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
      icon: Icons.cloud_off,
    );
  }

  factory ErrorDisplayWidget.noData({VoidCallback? onRefresh}) {
    return ErrorDisplayWidget(
      title: 'No Data Found',
      message: 'We couldn\'t find any data matching your request.',
      buttonText: 'Refresh',
      onButtonPressed: onRefresh,
      icon: Icons.search_off,
    );
  }

  factory ErrorDisplayWidget.permission({VoidCallback? onAction}) {
    return ErrorDisplayWidget(
      title: 'Permission Denied',
      message: 'You don\'t have permission to access this feature. Please upgrade your subscription.',
      buttonText: 'Upgrade Plan',
      onButtonPressed: onAction,
      icon: Icons.lock,
    );
  }

  factory ErrorDisplayWidget.noConnection({VoidCallback? onRetry}) {
    return ErrorDisplayWidget(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
      icon: Icons.signal_wifi_off,
    );
  }

  factory ErrorDisplayWidget.custom({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    IconData icon = Icons.error_outline,
    bool showButton = true,
  }) {
    return ErrorDisplayWidget(
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      icon: icon,
      showButton: showButton,
    );
  }
}
