import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/core/helpers/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _defaultLocation = LatLng(30.0444, 31.2357);
  final _mapController = MapController();
  late LatLng _selectedLocation;
  bool _gettingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,
              onTap: (_, point) => setState(() => _selectedLocation = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'clean_arch_session',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_pin,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          PositionedDirectional(
            top: 16,
            end: 16,
            child: FloatingActionButton.small(
              heroTag: 'current-location',
              onPressed: _gettingCurrentLocation ? null : _goToCurrentLocation,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              child: _gettingCurrentLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.strongShadow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tap the map to choose your delivery location',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_selectedLocation.latitude.toStringAsFixed(6)}, '
                      '${_selectedLocation.longitude.toStringAsFixed(6)}',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.pop(context, _selectedLocation),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Confirm Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _gettingCurrentLocation = true);
    try {
      final location = await LocationHelper.getCurrentLocation();
      if (!mounted) return;
      setState(() => _selectedLocation = location);
      _mapController.move(location, 16);
    } on LocationFailure catch (failure) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: failure.canOpenSettings
              ? SnackBarAction(
                  label: 'Settings',
                  onPressed: () => LocationHelper.openSettings(failure),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _gettingCurrentLocation = false);
    }
  }
}
