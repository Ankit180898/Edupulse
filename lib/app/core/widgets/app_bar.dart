import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final Widget? flexibleSpace;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0.0,
    this.flexibleSpace,
    this.centerTitle = true,
    this.bottom,
    this.toolbarHeight,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      elevation: elevation,
      leading: showBackButton
          ? _buildBackButton()
          : leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, size: 20),
      onPressed: onBackPressed ?? () => Get.back(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
