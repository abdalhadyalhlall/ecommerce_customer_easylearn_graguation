import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/ui/screen/profile_screen.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_cubit.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_state.dart';
import 'package:clean_arch_session/feature/store/presentation/ui/screen/product_details_screen.dart';
import 'package:clean_arch_session/feature/store/presentation/ui/screen/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widget/store_widgets.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _tabIndex = 0;
  Future<void>? _catalogRefreshInProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = context.read<StoreCubit>();
      store.loadCategories();
      store.loadProducts();
      store.loadCart();
      store.loadFavorites();
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Home', 'Favorites', 'My Cart', 'My Orders', 'Profile'];
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreCubit, StoreState>(
          listenWhen: (previous, current) =>
              previous.error != current.error ||
              previous.message != current.message,
          listener: (context, state) {
            final text = state.error ?? state.message;
            if (text == null) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(text),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            context.read<StoreCubit>().clearFeedback();
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
              if (state.message.isNotEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: _tabIndex == 0
            ? null
            : AppBar(
                backgroundColor: AppColors.canvas,
                title: Text(titles[_tabIndex]),
              ),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tabIndex,
            children: [
              _CatalogTab(
                onRefresh: _refreshCatalog,
                onProfileTap: () => _selectTab(4),
              ),
              const _FavoritesTab(),
              _CartTab(onNavigate: _selectTab),
              const _OrdersTab(),
              ProfileScreen(
                onOpenFavorites: () => _selectTab(1),
                onOpenOrders: () => _selectTab(3),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (index) {
            setState(() => _tabIndex = index);
            if (index == 0) {
              _refreshCatalog();
            } else if (index == 1) {
              context.read<StoreCubit>().loadFavorites();
            } else if (index == 2) {
              context.read<StoreCubit>().loadCart();
            } else if (index == 3) {
              context.read<StoreCubit>().loadOrders();
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: 'Faves',
            ),
            NavigationDestination(
              icon: const _CartNavigationIcon(
                icon: Icons.shopping_bag_outlined,
              ),
              selectedIcon: const _CartNavigationIcon(
                icon: Icons.shopping_bag_rounded,
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _tabIndex = index);
    if (index == 1) {
      context.read<StoreCubit>().loadFavorites();
    } else if (index == 3) {
      context.read<StoreCubit>().loadOrders();
    }
  }

  Future<void> _refreshCatalog() {
    final inProgress = _catalogRefreshInProgress;
    if (inProgress != null) return inProgress;

    final store = context.read<StoreCubit>();
    final refresh = _performCatalogRefresh(store);
    _catalogRefreshInProgress = refresh;
    return refresh.whenComplete(() {
      if (identical(_catalogRefreshInProgress, refresh)) {
        _catalogRefreshInProgress = null;
      }
    });
  }

  Future<void> _performCatalogRefresh(StoreCubit store) async {
    await Future.wait([
      store.loadCategories(),
      store.loadProducts(
        categorySlug: store.state.selectedCategorySlug,
        refresh: true,
      ),
    ]);
  }
}
