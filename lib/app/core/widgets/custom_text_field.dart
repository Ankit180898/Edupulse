import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edupulse/app/core/values/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool autofocus;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.autofocus = false,
    this.fillColor,
    this.filled = true,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.textAlign = TextAlign.start,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Dynamic colors based on theme
    final Color defaultFillColor = isDarkMode 
      ? const Color(0xFF1E1E1E)  // Dark mode fill color
      : Colors.white;

    final Color defaultBorderColor = isDarkMode 
      ? Colors.grey.shade700 
      : Colors.grey.shade300;

    final Color primaryColor = isDarkMode 
      ? AppColors.primaryLightColor 
      : AppColors.primaryColor;

    final Color textColor = isDarkMode 
      ? Colors.white 
      : AppColors.primaryTextColor;

    final Color secondaryTextColor = isDarkMode 
      ? Colors.grey.shade400 
      : AppColors.secondaryTextColor;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: textInputAction == TextInputAction.newline 
        ? TextInputType.multiline 
        : keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: textInputAction == TextInputAction.newline ? null : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      validator: validator,
      autofocus: autofocus,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      style: style ?? TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: secondaryTextColor) : prefix,
        suffixIcon: suffixIcon,
        suffix: suffix,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: filled,
        fillColor: fillColor ?? defaultFillColor,
        border: border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        enabledBorder: enabledBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        focusedBorder: focusedBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: errorBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.errorColor),
        ),
        disabledBorder: disabledBorder ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
        hintStyle: hintStyle ?? TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400
        ),
        labelStyle: labelStyle ?? TextStyle(
          color: isDarkMode ? Colors.grey.shade300 : secondaryTextColor
        ),
        errorStyle: errorStyle ?? TextStyle(color: AppColors.errorColor),
        counterText: '',
      ),
    );
  }
}