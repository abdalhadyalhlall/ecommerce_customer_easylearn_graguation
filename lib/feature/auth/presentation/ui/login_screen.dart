import 'package:e_commerce_customer/core/helpers/app_helpers.dart';
import 'package:e_commerce_customer/core/assets/app_assets.dart';
import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/core/routes/routes.dart';
import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce_customer/core/widgets/app_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _openOtp(String email) {
    context.pushNamed(Routes.otp, arguments: email);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthOtpRequired) {
                _openOtp(state.email);
              } else if (state is AuthFailure) {
                context.showSnackBar(state.message, isError: true);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 430.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: _ShopMark(size: 132.r)),
                          verticalSpace(20),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          verticalSpace(5),
                          Text(
                            'Sign in to continue shopping',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13.sp,
                            ),
                          ),
                          verticalSpace(28),
                          _AuthField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty ||
                                  !email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          verticalSpace(14),
                          _AuthField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 19.r,
                                color: AppColors.muted,
                              ),
                            ),
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Enter your password'
                                : null,
                            onSubmitted: (_) => _login(),
                          ),
                          verticalSpace(23),
                          AppButton(
                            text: 'Login',
                            isLoading: state is AuthLoading,
                            backgroundColor: AppColors.primary,
                            onPressed: _login,
                          ),
                          verticalSpace(10),
                          TextButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () => context.pushNamed(Routes.register),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.muted,
                                ),
                                children: [
                                  TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShopMark extends StatelessWidget {
  final double size;

  const _ShopMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.strongShadow,
            blurRadius: 16.r,
            offset: Offset(0.r, 5.r),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Image.asset(
          AppAssets.easyShopLogo,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.shopping_bag_rounded,
            color: AppColors.primary,
            size: 42.r,
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _AuthField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.onSubmitted,
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
          obscureText: obscureText,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: label == 'Email' ? 'you@example.com' : '••••••••',
            hintStyle: TextStyle(color: AppColors.muted, fontSize: 13.sp),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.r,
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
