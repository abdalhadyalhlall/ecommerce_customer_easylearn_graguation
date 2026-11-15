part of '../screen/store_screen.dart';

class _CartNavigationIcon extends StatelessWidget {
  final IconData icon;

  const _CartNavigationIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) => Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (state.cartItems.isNotEmpty)
            Positioned(
              top: -7.r,
              right: -9.r,
              child: Container(
                constraints: BoxConstraints(minWidth: 17.w, minHeight: 17.h),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 4.r),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${state.cartItems.length}',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final VoidCallback onProfileTap;

  const _CatalogTab({required this.onRefresh, required this.onProfileTap});

  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        final profileName =
            context.read<ProfileCubit>().state.profile?.name ?? 'Guest';
        final products = state.products.where((product) {
          final query = _searchQuery.toLowerCase();
          return product.name.toLowerCase().contains(query) ||
              (product.categoryName?.toLowerCase().contains(query) ?? false);
        }).toList();
        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: CustomScrollView(
            key: ValueKey(state.catalogRevision),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _CatalogHeader(
                  name: profileName,
                  searchController: _searchController,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                  onProfileTap: widget.onProfileTap,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.r, 15.r, 16.r, 0.r),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 52.h,
                      child: state.loadingCategories && state.categories.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : ListView(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                16.r,
                                8.r,
                                16.r,
                                6.r,
                              ),
                              scrollDirection: Axis.horizontal,
                              children: [
                                _CategoryChip(
                                  label: 'All',
                                  selected: state.selectedCategorySlug == null,
                                  onTap: () =>
                                      context.read<StoreCubit>().loadProducts(),
                                ),
                                ...state.categories.map(
                                  (category) => _CategoryChip(
                                    label: category.name,
                                    selected:
                                        category.slug ==
                                        state.selectedCategorySlug,
                                    onTap: () =>
                                        context.read<StoreCubit>().loadProducts(
                                          categorySlug: category.slug,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.r,
                        7.r,
                        16.r,
                        5.r,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Products',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${products.length} items',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(16.r, 5.r, 16.r, 20.r),
                sliver: state.loadingProducts && state.products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : state.products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products found',
                          subtitle: 'Try another category or refresh the list.',
                        ),
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = products[index];
                          return _ProductCard(
                            product: product,
                            isFavorite: state.isFavorite(product.id),
                            onToggleFavorite: () => context
                                .read<StoreCubit>()
                                .toggleFavorite(product),
                            onTap: () => _showProductDetails(context, product),
                          );
                        }, childCount: products.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.69,
                            ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showProductDetails(
    BuildContext context,
    StoreProduct product,
  ) async {
    final storeCubit = context.read<StoreCubit>();
    final details = await storeCubit.loadProductDetails(product.slug);
    if (!context.mounted || details == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: storeCubit,
          child: ProductDetailsScreen(product: details),
        ),
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  final String name;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onProfileTap;

  const _CatalogHeader({
    required this.name,
    required this.searchController,
    required this.onSearchChanged,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.r, 22.r, 16.r, 0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOOD MORNING,',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 10.sp,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$name 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh products',
                onPressed: () => context.read<StoreCubit>().loadProducts(
                  categorySlug: context
                      .read<StoreCubit>()
                      .state
                      .selectedCategorySlug,
                  refresh: true,
                ),
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                  size: 20.r,
                ),
              ),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(22.r),
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _profileInitials(name),
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: AppColors.muted, fontSize: 12.sp),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.muted,
                size: 19.r,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.symmetric(vertical: 10.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _profileInitials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return String.fromCharCode(parts.first.runes.first).toUpperCase();
    }
    return '${String.fromCharCode(parts.first.runes.first)}'
            '${String.fromCharCode(parts.last.runes.first)}'
        .toUpperCase();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8.r),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.surface : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingFavorites && state.favorites.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.favorites.isEmpty) {
          return const _EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No favorites yet',
            subtitle: 'Save products you love and find them here.',
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<StoreCubit>().loadFavorites,
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.favorites.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = state.favorites[index];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: () => _openProductDetails(context, item.product),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13.r),
                          child: SizedBox(
                            width: 68.w,
                            height: 68.h,
                            child: _ProductImage(url: item.product.image),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.categoryName ?? '',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11.sp,
                                ),
                              ),
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${_price(item.product.price)} EGP',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.product.publisher != null)
                                Text(
                                  'by ${item.product.publisher!.displayName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove from favorites',
                          onPressed: () => context
                              .read<StoreCubit>()
                              .toggleFavorite(item.product),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openProductDetails(
    BuildContext context,
    StoreProduct product,
  ) async {
    final cubit = context.read<StoreCubit>();
    final details = await cubit.loadProductDetails(product.slug);
    if (!context.mounted || details == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProductDetailsScreen(product: details),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StoreProduct product;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: _ProductImage(url: product.image),
                      ),
                    ),
                    PositionedDirectional(
                      top: 8.r,
                      end: 8.r,
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: onToggleFavorite,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(
                            alpha: 0.9,
                          ),
                          minimumSize: Size(34.r, 34.r),
                        ),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? AppColors.error : AppColors.muted,
                          size: 19.r,
                        ),
                      ),
                    ),
                    if (!product.isInStock)
                      const Center(
                        child: Chip(
                          label: Text('Out of Stock'),
                          backgroundColor: AppColors.surface,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 11.h),
              if (product.categoryName != null)
                Text(
                  product.categoryName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              SizedBox(height: 4.h),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (product.publisher != null) ...[
                SizedBox(height: 3.h),
                Text(
                  'by ${product.publisher!.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.muted, fontSize: 10.sp),
                ),
              ],
              SizedBox(height: 9.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _price(product.price),
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18.r,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? url;

  const _ProductImage({this.url});

  @override
  Widget build(BuildContext context) {
    final parsed = url == null ? null : Uri.tryParse(url!);
    if (parsed == null || !parsed.hasAbsolutePath || parsed.host.isEmpty) {
      return const _ImagePlaceholder();
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.primary,
          size: 42.r,
        ),
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _CartTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingCart && state.cartItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.cartItems.isEmpty) {
          return const _EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            subtitle: 'Explore products and add the items you like.',
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: state.cartItems.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) =>
                    _CartItemCard(item: state.cartItems[index]),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.r, 17.r, 20.r, 18.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16.r,
                    offset: Offset(0.r, -4.r),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Subtotal',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        Text(
                          '${_price(state.cartTotal)} EGP',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${_price(state.cartTotal)} EGP',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 15.r),
                        ),
                        onPressed: state.busy
                            ? null
                            : () => _startCheckout(context),
                        child: state.busy
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.r,
                                  color: AppColors.surface,
                                ),
                              )
                            : const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startCheckout(BuildContext context) async {
    final storeCubit = context.read<StoreCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final showOrders = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: storeCubit),
            BlocProvider.value(value: profileCubit),
          ],
          child: const CheckoutScreen(),
        ),
      ),
    );
    if (!context.mounted || showOrders == null) return;
    onNavigate(showOrders ? 3 : 0);
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreCubit>();
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: SizedBox(
              width: 76.w,
              height: 76.h,
              child: _ProductImage(url: item.product.image),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _price(item.subtotal),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove item',
            onPressed: () => store.removeCartItem(item),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.loadingOrders && state.orders.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.orders.isEmpty) {
          return const _EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Your orders will appear here after checkout.',
          );
        }
        return RefreshIndicator(
          onRefresh: context.read<StoreCubit>().loadOrders,
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: state.orders.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _OrderCard(
              order: state.orders[index],
              onTap: () => _showOrderDetails(context, state.orders[index]),
              onPay:
                  state.orders[index].paymentMethod.toLowerCase() == 'card' &&
                      _isPayableStatus(state.orders[index].status)
                  ? () => context.read<StoreCubit>().payForOrder(
                      state.orders[index],
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOrderDetails(BuildContext context, StoreOrder order) async {
    final details = await context.read<StoreCubit>().loadOrderDetails(
      order.code,
    );
    if (!context.mounted || details == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: SizedBox(
          width: 360.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Order: ${details.code}'),
              SizedBox(height: 8.h),
              Text('Status: ${_statusLabel(details.status)}'),
              Text('Payment: ${_paymentLabel(details.paymentMethod)}'),
              if (details.address.isNotEmpty)
                Text('Address: ${details.address}'),
              Divider(height: 24.h),
              ...details.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.r),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} × ${item.quantity}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(_price(item.totalPrice)),
                    ],
                  ),
                ),
              ),
              Divider(height: 24.h),
              Text(
                'Total: ${_price(details.totalPrice)} EGP',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: context.pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final StoreOrder order;
  final VoidCallback onTap;
  final VoidCallback? onPay;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.code}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        _OrderStatusBadge(status: order.status),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            '${order.items.length} items',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _paymentLabel(order.paymentMethod),
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _price(order.totalPrice),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (onPay != null)
                    TextButton(onPressed: onPay, child: const Text('Pay now')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.w,
              height: 84.h,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 38.r),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

String _price(double value) => value.toStringAsFixed(2);

String _statusLabel(String status) {
  return _statusStyle(status).label;
}

bool _isPayableStatus(String status) {
  final normalized = status.toLowerCase().replaceAll('_', ' ').trim();
  return normalized == 'pending' ||
      normalized == 'unpaid' ||
      normalized == 'awaiting payment';
}

({String label, Color foreground, Color background}) _statusStyle(
  String status,
) {
  final normalized = status.toLowerCase().replaceAll('_', ' ').trim();
  switch (normalized) {
    case 'pending':
    case 'unpaid':
    case 'awaiting payment':
      return (
        label: 'Pending',
        foreground: AppColors.primary,
        background: AppColors.primaryContainer,
      );
    case 'processing':
    case 'confirmed':
    case 'paid':
      return (
        label: normalized == 'paid' ? 'Paid' : 'Processing',
        foreground: const Color(0xFF2167C5),
        background: const Color(0xFFE7F0FF),
      );
    case 'shipped':
    case 'in transit':
    case 'on the way':
      return (
        label: 'Shipped',
        foreground: const Color(0xFF2167C5),
        background: const Color(0xFFE7F0FF),
      );
    case 'completed':
    case 'delivered':
      return (
        label: 'Completed',
        foreground: AppColors.success,
        background: AppColors.successContainer,
      );
    case 'cancelled':
    case 'canceled':
      return (
        label: 'Cancelled',
        foreground: AppColors.error,
        background: const Color(0xFFFFE9E5),
      );
    case 'failed':
    case 'rejected':
      return (
        label: 'Failed',
        foreground: AppColors.error,
        background: const Color(0xFFFFE9E5),
      );
    default:
      return (
        label: status.trim().isEmpty ? 'Unknown' : status,
        foreground: AppColors.muted,
        background: const Color(0xFFF0F0F0),
      );
  }
}

String _paymentLabel(String method) {
  switch (method.toLowerCase()) {
    case 'card':
      return 'Card';
    case 'cash':
      return 'Cash on Delivery';
    default:
      return method;
  }
}
