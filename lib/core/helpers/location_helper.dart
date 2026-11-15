import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationFailure implements Exception {
  serviceDisabled('Turn on location services to use your current location.'),
  denied('Location permission is needed to get your location.'),
  deniedForever(
    'Location permission is blocked. Allow it from the app settings.',
  ),
  unavailable('Could not get your location. Please try again.'),
  addressUnavailable('Could not find an address for the selected location.');

  const LocationFailure(this.message);

  final String message;

  bool get canOpenSettings =>
      this == deniedForever || this == serviceDisabled;
}

class LocationHelper {
  const LocationHelper._();

  static Future<LatLng> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationFailure.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw LocationFailure.denied;
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationFailure.deniedForever;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } on LocationFailure {
      rethrow;
    } catch (_, stackTrace) {
      Error.throwWithStackTrace(LocationFailure.unavailable, stackTrace);
    }
  }

  static Future<String> getAddressFromCoordinates(LatLng location) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isEmpty) throw LocationFailure.addressUnavailable;
      final place = placemarks.first;
      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].whereType<String>().map((part) => part.trim()).where((part) => part.isNotEmpty).toSet();
      final address = addressParts.join(', ');
      if (address.isEmpty) throw LocationFailure.addressUnavailable;
      return address;
    } on LocationFailure {
      rethrow;
    } catch (_, stackTrace) {
      Error.throwWithStackTrace(LocationFailure.addressUnavailable, stackTrace);
    }
  }

  static Future<bool> openSettings(LocationFailure failure) {
    return switch (failure) {
      LocationFailure.serviceDisabled => Geolocator.openLocationSettings(),
      LocationFailure.deniedForever => Geolocator.openAppSettings(),
      _ => Future.value(false),
    };
  }
}
