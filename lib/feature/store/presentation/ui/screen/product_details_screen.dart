import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_cubit.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_state.dart';
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
                        ? const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.surface,
                            size: 78,
                          )
                        : Image.network(
                            product.image!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.surface,
                              size: 78,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    child: _RoundActionButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                children: [
                  if (product.categoryName != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          product.categoryName!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product.price.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (product.publisher != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sold by ${product.publisher!.displayName}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          product.description.isEmpty
                              ? 'No additional description available.'
                              : product.description,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? AppColors.successContainer.withValues(
                                    alpha: 0.55,
                                  )
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                product.isInStock ? 'In Stock' : 'Out of Stock',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                product.isInStock
                                    ? '${product.quantity} units'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color: product.isInStock
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                icon: const Icon(Icons.remove, size: 15),
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed:
                                    _quantity < product.quantity &&
                                        product.isInStock
                                    ? () => setState(() => _quantity++)
                                    : null,
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 15,
                                ),
                              ),
                            ],
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed:
                        !product.isVisible ||
                            !product.isInStock ||
                            _addingToCart
                        ? null
                        : _addedToCart
                        ? () => Navigator.pop(context)
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
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
        icon: Icon(icon, color: iconColor, size: 19),
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
