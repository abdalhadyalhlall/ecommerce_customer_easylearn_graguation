import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/feature/store/domain/entities/store_entities.dart';
import 'package:e_commerce_customer/feature/store/presentation/cubit/store_cubit.dart';
import 'package:e_commerce_customer/feature/store/presentation/cubit/store_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final StoreProduct product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _addedToCart = false;
  bool _addingToCart = false;

  Future<void> _addToCart() async {
    if (_addingToCart ||
        !widget.product.isVisible ||
        !widget.product.isInStock) {
      return;
    }
    setState(() => _addingToCart = true);
    final cubit = context.read<StoreCubit>();
    await cubit.addToCart(widget.product, quantity: _quantity);
    if (!mounted) return;
    setState(() {
      _addingToCart = false;
      _addedToCart = cubit.state.cartItems.any(
        (item) => item.product.id == widget.product.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.34,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5799FF), Color(0xFF635BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: product.image == null || product.image!.isEmpty
                        ? Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.surface,
                            size: 78.r,
                          )
                        : Image.network(
                            product.image!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.surface,
                              size: 78.r,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12.r,
                    left: 16.r,
                    child: _RoundActionButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: context.pop,
                    ),
                  ),
                  Positioned(
                    top: 12.r,
                    right: 16.r,
                    child: BlocBuilder<StoreCubit, StoreState>(
                      builder: (context, state) {
                        final isFavorite = state.isFavorite(product.id);
                        return _RoundActionButton(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor: isFavorite
                              ? AppColors.error
                              : AppColors.muted,
                          onPressed: () => context
                              .read<StoreCubit>()
                              .toggleFavorite(product),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.r, 16.r, 18.r, 20.r),
                children: [
                  if (product.categoryName != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.r,
                          vertical: 5.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          product.categoryName!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 7.h),
                  Text(
                    product.name,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${product.price.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (product.publisher != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 15.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Sold by ${product.publisher!.displayName}',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(13.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          product.description.isEmpty
                              ? 'No additional description available.'
                              : product.description,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14.sp,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.r),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? AppColors.successContainer.withValues(
                                    alpha: 0.55,
                                  )
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                product.isInStock ? 'In Stock' : 'Out of Stock',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                product.isInStock
                                    ? '${product.quantity} units'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color: product.isInStock
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.r,
                            vertical: 4.r,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                  icon: Icon(Icons.remove, size: 15.r),
                                ),
                                Text(
                                  '$_quantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed:
                                      _quantity < product.quantity &&
                                          product.isInStock
                                      ? () => setState(() => _quantity++)
                                      : null,
                                  icon: Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 15.r,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 12.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton.icon(
                    onPressed:
                        !product.isVisible ||
                            !product.isInStock ||
                            _addingToCart
                        ? null
                        : _addedToCart
                        ? context.pop
                        : _addToCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: _addedToCart
                          ? AppColors.successContainer
                          : AppColors.primary,
                      foregroundColor: _addedToCart
                          ? AppColors.success
                          : AppColors.surface,
                    ),
                    icon: _addingToCart
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: CircularProgressIndicator(strokeWidth: 2.r),
                          )
                        : Icon(
                            _addedToCart
                                ? Icons.check_circle_outline_rounded
                                : Icons.add_shopping_cart_rounded,
                          ),
                    label: Text(
                      _addingToCart
                          ? 'Adding...'
                          : _addedToCart
                          ? 'Added to Cart!'
                          : 'Add to Cart',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _RoundActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 19.r),
        constraints: BoxConstraints.tightFor(width: 40.w, height: 40.h),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
