import 'dart:typed_data';

import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String name;
  final double radius;
  final Widget? badge;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.imageBytes,
    this.radius = 30,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final image = imageUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          child: imageBytes != null
              ? Image.memory(imageBytes!, fit: BoxFit.cover)
              : image == null || image.isEmpty
              ? _initialLabel()
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _initialLabel(),
                ),
        ),
        if (badge != null)
          PositionedDirectional(bottom: -2.r, end: -2.r, child: badge!),
      ],
    );
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'U';
    final first = words.first.runes.first;
    if (words.length == 1) {
      final letters = words.first.runes.take(2).toList();
      return String.fromCharCode(letters.first).toUpperCase() +
          (letters.length > 1 ? String.fromCharCode(letters[1]) : '');
    }
    return '${String.fromCharCode(first)}'
            '${String.fromCharCode(words.last.runes.first)}'
        .toUpperCase();
  }

  Widget _initialLabel() {
    return Text(
      _initials(name),
      style: TextStyle(
        color: AppColors.surface,
        fontSize: radius * 0.55,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 21.r),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.muted,
        size: 20.r,
      ),
      minLeadingWidth: 18.w,
      minTileHeight: 54.h,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.r),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 13.r,
              vertical: 13.r,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileFeedback extends StatelessWidget {
  final String text;
  final bool isError;

  const ProfileFeedback({super.key, required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    final background = isError
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.success.withValues(alpha: 0.08);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: color,
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
