import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_state.dart';
import 'package:e_commerce_customer/feature/profile/presentation/ui/screen/edit_profile_screen.dart';
import 'package:e_commerce_customer/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenFavorites;
  final VoidCallback onOpenOrders;

  const ProfileScreen({
    super.key,
    required this.onOpenFavorites,
    required this.onOpenOrders,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.loading && state.profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final profile = state.profile;
        if (profile == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    color: AppColors.muted,
                    size: 42.r,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    state.error ?? 'Unable to load your profile.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: context.read<ProfileCubit>().loadProfile,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<ProfileCubit>().loadProfile,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 24.r),
            children: [
              if (state.error != null || state.message != null) ...[
                ProfileFeedback(
                  text: state.error ?? state.message!,
                  isError: state.error != null,
                ),
                SizedBox(height: 10.h),
              ],
              _ProfileSummary(
                name: profile.name,
                email: profile.email,
                phone: profile.phone,
                imageUrl: profile.pictureUrl,
              ),
              SizedBox(height: 12.h),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18.r),
                elevation: 2,
                shadowColor: AppColors.shadow,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      onTap: () => _openEditor(context),
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      onTap: () => _openEditor(context),
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'My Orders',
                      onTap: onOpenOrders,
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      onTap: onOpenFavorites,
                    ),
                    _separator(),
                    ProfileMenuTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () => _openEditor(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 45.h,
                child: TextButton.icon(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  icon: Icon(Icons.logout_rounded, size: 16.r),
                  label: const Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _separator() => Divider(
    height: 1.h,
    indent: 46.w,
    endIndent: 14.w,
    color: AppColors.border,
  );

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;

  const _ProfileSummary({
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12.r,
            offset: Offset(0.r, 3.r),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(imageUrl: imageUrl, name: name, radius: 29.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
