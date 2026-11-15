import 'dart:typed_data';

import 'package:clean_arch_session/core/helpers/image_picker_helper.dart';
import 'package:clean_arch_session/core/helpers/location_picker_helper.dart';
import 'package:clean_arch_session/core/theme/app_colors.dart';
import 'package:clean_arch_session/core/widgets/app_button.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:clean_arch_session/feature/profile/presentation/cubit/profile_state.dart';
import 'package:clean_arch_session/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  Uint8List? _pictureBytes;
  String? _pictureFileName;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state.profile;
    if (profile == null) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address ?? '';
    _latitudeController.text = profile.latitude?.toString() ?? '';
    _longitudeController.text = profile.longitude?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    try {
      final image = await ImagePickerHelper.showPicker(context);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pictureBytes = bytes;
        _pictureFileName = image.name;
      });
    } on PickImageFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read the selected picture: $error')),
      );
    }
  }

  Future<void> _editLocation() async {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    final result = await LocationPickerHelper.pickLocation(
      context,
      initialLocation: latitude == null || longitude == null
          ? null
          : LatLng(latitude, longitude),
    );
    if (result == null || !mounted) return;
    setState(() {
      _latitudeController.text = result.latitude.toStringAsFixed(6);
      _longitudeController.text = result.longitude.toStringAsFixed(6);
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _optionalCoordinate(_latitudeController.text),
      longitude: _optionalCoordinate(_longitudeController.text),
      pictureBytes: _pictureBytes,
      pictureFileName: _pictureFileName,
    );
  }

  double? _optionalCoordinate(String value) =>
      value.trim().isEmpty ? null : double.parse(value.trim());

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileCubit>().state.profile;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                    children: [
                      Center(
                        child: InkWell(
                          onTap: state.saving ? null : _pickPicture,
                          borderRadius: BorderRadius.circular(40),
                          child: ProfileAvatar(
                            imageUrl: _pictureBytes == null
                                ? profile?.pictureUrl
                                : null,
                            imageBytes: _pictureBytes,
                            name: _nameController.text,
                            radius: 27,
                            badge: Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.surface,
                                size: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_pictureBytes != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _pictureFileName ?? '',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ProfileTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      ProfileTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 12),
                      ProfileTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter your phone number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      ProfileTextField(
                        controller: _addressController,
                        label: 'Address',
                        keyboardType: TextInputType.streetAddress,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: state.saving ? null : _editLocation,
                        icon: const Icon(Icons.location_on_outlined, size: 17),
                        label: Text(
                          _locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: AlignmentDirectional.centerStart,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primaryBorder,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                      if (state.error != null || state.message != null) ...[
                        const SizedBox(height: 10),
                        ProfileFeedback(
                          text: state.error ?? state.message!,
                          isError: state.error != null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Save Changes',
                        onPressed: _save,
                        isLoading: state.saving,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String get _locationLabel {
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();
    if (latitude.isEmpty && longitude.isEmpty) {
      return 'Location — tap to update on map';
    }
    return 'Location — $latitude, $longitude';
  }
}
