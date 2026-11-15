import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/feature/store/domain/entities/store_entities.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final StoreOrder order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderStatus = order.status.toLowerCase().replaceAll('_', ' ').trim();
    final paymentPending =
        order.paymentMethod.toLowerCase() == 'card' &&
        const ['pending', 'unpaid', 'awaiting payment'].contains(orderStatus);
    return Scaffold(
      backgroundColor: const Color(0xFFF2FCF6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420.w),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76.w,
                          height: 76.h,
                          decoration: const BoxDecoration(
                            color: AppColors.successContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            size: 42.r,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          paymentPending
                              ? 'Complete Your Payment'
                              : 'Order Placed Successfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          paymentPending
                              ? 'The Paymob payment page was opened. Your order will remain pending until payment is confirmed.'
                              : 'Your order has been placed successfully.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          '#${order.code}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 26.h),
                        SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: Icon(Icons.receipt_long_rounded, size: 17.r),
                            label: const Text('View Orders'),
                          ),
                        ),
                        SizedBox(height: 9.h),
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primaryBorder,
                              ),
                            ),
                            child: const Text('Continue Shopping'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
