import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/core/helpers/location_picker_helper.dart';
import 'package:e_commerce_customer/core/helpers/location_helper.dart';
import 'package:e_commerce_customer/core/helpers/app_helpers.dart';
import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_state.dart';
import 'package:e_commerce_customer/feature/profile/domain/entities/client_profile.dart';
import 'package:e_commerce_customer/feature/store/domain/entities/store_entities.dart';
import 'package:e_commerce_customer/feature/store/presentation/cubit/store_cubit.dart';
import 'package:e_commerce_customer/feature/store/presentation/cubit/store_state.dart';
import 'package:e_commerce_customer/feature/store/presentation/ui/screen/order_success_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      context.showSnackBar(failure.message, isError: true);
    }
  }

  Future<void> _placeOrder() async {
    final address = _deliveryAddress?.trim() ?? '';
    if (address.isEmpty) {
      context.showSnackBar(
        'No saved address was found. Choose a delivery location on the map or add an address to your profile.',
        isError: true,
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
        title: Text(
          'Checkout',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
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
                    padding: EdgeInsets.fromLTRB(18.r, 18.r, 18.r, 22.r),
                    children: [
                      _CheckoutSection(
                        title: 'Delivery Address',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.r,
                                vertical: 13.r,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primary,
                                    size: 22.r,
                                  ),
                                  horizontalSpace(10),
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
                                        fontSize: 16.sp,
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
                                icon: Icon(
                                  Icons.location_on_outlined,
                                  size: 20.r,
                                ),
                                label: Text(
                                  _locationChanged
                                      ? 'Location updated · Change again'
                                      : 'Change Location',
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _CheckoutSection(
                        title: 'Order Items',
                        child: Column(
                          children: state.cartItems
                              .map((item) => _CheckoutItem(item: item))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),
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
                            SizedBox(height: 8.h),
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
                      SizedBox(height: 16.h),
                      _CheckoutSection(
                        title: 'Order Summary',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Items (${state.cartItems.length})',
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                ),
                                Text(
                                  '${state.cartTotal.toStringAsFixed(0)} EGP',
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ],
                            ),
                            Divider(height: 20.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${state.cartTotal.toStringAsFixed(0)} EGP',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 22.sp,
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
                    padding: EdgeInsets.fromLTRB(18.r, 10.r, 18.r, 16.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58.h,
                      child: FilledButton(
                        onPressed: state.busy ? null : _placeOrder,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: state.busy
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.r,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                _paymentMethod == 'card'
                                    ? 'Continue to Paymob'
                                    : 'Place Order',
                                style: TextStyle(
                                  fontSize: 16.sp,
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
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0.r, 3.r),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14.h),
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
      padding: EdgeInsets.only(bottom: 8.r),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 66.w,
              height: 66.h,
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
          horizontalSpace(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: AppColors.muted, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          Text(
            '${item.subtotal.toStringAsFixed(0)} EGP',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15.sp,
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 15.r),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.muted,
              size: 23.r,
            ),
            horizontalSpace(8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.muted,
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}
