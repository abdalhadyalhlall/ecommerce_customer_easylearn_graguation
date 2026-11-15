import 'package:e_commerce_customer/core/widgets/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerHelper {
  const LocationPickerHelper._();

  static Future<LatLng?> pickLocation(
    BuildContext context, {
    LatLng? initialLocation,
  }) {
    return Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: initialLocation),
      ),
    );
  }
}
