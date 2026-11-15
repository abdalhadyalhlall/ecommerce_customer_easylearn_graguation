import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/core/helpers/location_picker_helper.dart';
import 'package:clean_arch_session/core/helpers/location_helper.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_state.dart';
import 'package:clean_arch_session/feature/profile/domain/entities/client_profile.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_cubit.dart';
import 'package:clean_arch_session/feature/store/presentation/cubit/store_state.dart';
import 'package:clean_arch_session/feature/store/presentation/ui/screen/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _deliveryAddress;
  double? _latitude;
  double? _longitude;
  String _paymentMethod = 'cash';
  bool _locationChanged = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state.profile;
    _deliveryAddress = profile?.address?.trim();
    _latitude = profile?.latitude;
    _longitude = profile?.longitude;
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final profileCubit = context.read<ProfileCubit>();
        if (!profileCubit.state.loading) profileCubit.loadProfile();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _changeLocation() async {
    final location = await LocationPickerHelper.pickLocation(
      context,
      initialLocation: _latitude == null || _longitude == null
          ? null
          : LatLng(_latitude!, _longitude!),
    );
    if (location == null || !mounted) return;
    try {
      final address = await LocationHelper.getAddressFromCoordinates(location);
      if (!mounted) return;
      setState(() {
        _deliveryAddress = address;
        _latitude = location.latitude;
        _longitude = location.longitude;
        _locationChanged = true;
      });
    } on LocationFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _placeOrder() async {
    final address = _deliveryAddress?.trim() ?? '';
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No saved address was found. Choose a delivery location on the map or add an address to your profile.',
          ),
        ),
      );
      return;
    }

    final cubit = context.read<StoreCubit>();
    final order = await cubit.placeOrder(
      address: address,
      latitude: _latitude,
      longitude: _longitude,
      paymentMethod: _paymentMethod,
    );
    if (order == null) {
      if (_paymentMethod == 'card' &&
          cubit.state.cartItems.isEmpty &&
          mounted) {
        Navigator.pop(context, true);
      }
      return;
    }
    if (!mounted) return;

    final showOrders = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
    if (mounted && showOrders != null) {
      Navigator.pop(context, showOrders);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.profile != current.profile && current.profile != null,
        listener: (context, state) => _applyProfile(state.profile),
        child: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                    children: [
                      _CheckoutSection(
                        title: 'Delivery Address',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _deliveryAddress?.isNotEmpty == true
                                          ? _deliveryAddress!
                                          : 'No delivery address saved',
                                      style: TextStyle(
                                        color:
                                            _deliveryAddress?.isNotEmpty == true
                                            ? AppColors.ink
                                            : AppColors.muted,
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: _changeLocation,
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  _locationChanged
                                      ? 'Location updated · Change again'
                                      : 'Change Location',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CheckoutSection(
                        title: 'Order Items',
                        child: Column(
                          children: state.cartItems
                              .map((item) => _CheckoutItem(item: item))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CheckoutSection(
                        title: 'Payment Method',
                        child: Column(
                          children: [
                            _PaymentChoice(
                              title: 'Cash on Delivery',
                              icon: Icons.payments_outlined,
                              selected: _paymentMethod == 'cash',
                              onTap: () =>
                                  setState(() => _paymentMethod = 'cash'),
                            ),
                            const SizedBox(height: 8),
                            _PaymentChoice(
                              title: 'Credit / Debit Card',
                              icon: Icons.credit_card_outlined,
                              selected: _paymentMethod == 'card',
                              onTap: () =>
                                  setState(() => _paymentMethod = 'card'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CheckoutSection(
                        title: 'Order Summary',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Items (${state.cartItems.length})',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  '${state.cartTotal.toStringAsFixed(0)} EGP',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${state.cartTotal.toStringAsFixed(0)} EGP',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        onPressed: state.busy ? null : _placeOrder,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: state.busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                _paymentMethod == 'card'
                                    ? 'Continue to Paymob'
                                    : 'Place Order',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _applyProfile(ClientProfile? profile) {
    if (!mounted || profile == null) return;
    var changed = false;
    if (!_locationChanged &&
        (_deliveryAddress == null || _deliveryAddress!.isEmpty) &&
        profile.address?.trim().isNotEmpty == true) {
      _deliveryAddress = profile.address!.trim();
      changed = true;
    }
    if (_latitude == null && profile.latitude != null) {
      _latitude = profile.latitude;
      changed = true;
    }
    if (_longitude == null && profile.longitude != null) {
      _longitude = profile.longitude;
      changed = true;
    }
    if (changed) setState(() {});
  }
}

class _CheckoutSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CheckoutSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  final CartItem item;

  const _CheckoutItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = item.product.image;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 66,
              height: 66,
              child: image == null || image.isEmpty
                  ? const ColoredBox(
                      color: AppColors.primaryContainer,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppColors.primaryContainer,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${item.subtotal.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentChoice({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.muted,
              size: 23,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
