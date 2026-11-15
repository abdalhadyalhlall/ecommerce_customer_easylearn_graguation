import 'dart:typed_data';

import 'package:e_commerce_customer/core/helpers/image_picker_helper.dart';
import 'package:e_commerce_customer/core/helpers/location_picker_helper.dart';
import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/core/theme/app_colors.dart';
import 'package:e_commerce_customer/core/widgets/app_button.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_state.dart';
import 'package:e_commerce_customer/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      context.showSnackBar(failure.message, isError: true);
    } catch (error) {
      if (!mounted) return;
      context.showSnackBar(
        'Could not read the selected picture: $error',
        isError: true,
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
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 520.w),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 22.r),
                    children: [
                      Center(
                        child: InkWell(
                          onTap: state.saving ? null : _pickPicture,
                          borderRadius: BorderRadius.circular(40.r),
                          child: ProfileAvatar(
                            imageUrl: _pictureBytes == null
                                ? profile?.pictureUrl
                                : null,
                            imageBytes: _pictureBytes,
                            name: _nameController.text,
                            radius: 27.r,
                            badge: Container(
                              width: 19.w,
                              height: 19.h,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.surface,
                                size: 11.r,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_pictureBytes != null) ...[
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            _pictureFileName ?? '',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      ProfileTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter your name'
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      ProfileTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      SizedBox(height: 12.h),
                      ProfileTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter your phone number'
                            : null,
                      ),
                      SizedBox(height: 12.h),
                      ProfileTextField(
                        controller: _addressController,
                        label: 'Address',
                        keyboardType: TextInputType.streetAddress,
                      ),
                      SizedBox(height: 10.h),
                      OutlinedButton.icon(
                        onPressed: state.saving ? null : _editLocation,
                        icon: Icon(Icons.location_on_outlined, size: 17.r),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.r,
                            vertical: 13.r,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                        ),
                      ),
                      if (state.error != null || state.message != null) ...[
                        SizedBox(height: 10.h),
                        ProfileFeedback(
                          text: state.error ?? state.message!,
                          isError: state.error != null,
                        ),
                      ],
                      SizedBox(height: 12.h),
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
