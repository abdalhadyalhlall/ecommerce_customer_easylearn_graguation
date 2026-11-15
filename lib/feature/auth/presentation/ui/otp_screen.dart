import 'dart:async';

import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/core/routes/routes.dart';
import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce_customer/core/widgets/app_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _otpLength = 6;
  final _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  Timer? _resendMessageTimer;
  String? _resendMessage;
  bool _verificationInProgress = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendMessageTimer?.cancel();
    super.dispose();
  }

  String get _otpCode =>
      _controllers.map((controller) => controller.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final rawDigits = value.replaceAll(RegExp(r'\D'), '');
      final availableLength = _otpLength - index;
      final digits = rawDigits.substring(
        0,
        rawDigits.length > availableLength ? availableLength : rawDigits.length,
      );
      for (var i = index; i < _otpLength; i++) {
        final digitIndex = i - index;
        if (digitIndex < digits.length) {
          _controllers[i].text = digits[digitIndex];
        }
      }
      if (index + digits.length == _otpLength) {
        _focusNodes.last.unfocus();
        _verify();
      } else {
        _focusNodes[index + digits.length].requestFocus();
      }
      return;
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (value.isNotEmpty && _otpCode.length == _otpLength) {
      _focusNodes.last.unfocus();
      _verify();
    }
  }

  void _verify() {
    if (_verificationInProgress) return;
    if (_otpCode.length != _otpLength) {
      context.showSnackBar(
        'Enter the 6-digit verification code',
        isError: true,
      );
      return;
    }
    _verificationInProgress = true;
    context.read<AuthCubit>().verifyOtp(email: widget.email, otpCode: _otpCode);
  }

  void _showResendMessage() {
    _resendMessageTimer?.cancel();
    setState(() => _resendMessage = 'OTP resent successfully!');
    _resendMessageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _resendMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          backgroundColor: AppColors.canvas,
          leading: IconButton(
            tooltip: 'Back',
            icon: Icon(Icons.arrow_back_rounded, size: 20.r),
            onPressed: context.pop,
          ),
          title: Text(
            'Verify OTP',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.pushNamedAndRemoveUntil(
                  Routes.welcome,
                  predicate: (route) => false,
                );
              } else if (state is AuthOtpResent) {
                _showResendMessage();
              } else if (state is AuthFailure) {
                _verificationInProgress = false;
                context.showSnackBar(state.message, isError: true);
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.r),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 430.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 58.w,
                            height: 58.h,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primary,
                              size: 27.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 27.h),
                        Text(
                          'Code sent to ${widget.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          children: List.generate(_otpLength, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == _otpLength - 1.r ? 0.r : 7.r,
                                ),
                                child: SizedBox(
                                  height: 48.h,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: _otpLength,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(9.r),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(9.r),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(9.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.4.w,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) =>
                                        _onDigitChanged(index, value),
                                    onSubmitted: (_) => _verify(),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_resendMessage != null) ...[
                          SizedBox(height: 15.h),
                          Text(
                            _resendMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        SizedBox(height: 22.h),
                        AppButton(
                          text: 'Verify OTP',
                          backgroundColor: AppColors.primary,
                          isLoading: state is AuthLoading,
                          onPressed: _verify,
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () => context.read<AuthCubit>().resendOtp(
                                  email: widget.email,
                                ),
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

class VerificationSuccessScreen extends StatefulWidget {
  const VerificationSuccessScreen({super.key});

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.pushNamedAndRemoveUntil(
          Routes.store,
          predicate: (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(28.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: const BoxDecoration(
                      color: AppColors.successContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 34.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Verified!',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Welcome to Easy Shop',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
