import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: AppColors.successContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    paymentPending
                        ? 'Complete Your Payment'
                        : 'Order Placed Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    paymentPending
                        ? 'The Paymob payment page was opened. Your order will remain pending until payment is confirmed.'
                        : 'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '#${order.code}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, size: 17),
                      label: const Text('View Orders'),
                    ),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryBorder),
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
    );
  }
}
