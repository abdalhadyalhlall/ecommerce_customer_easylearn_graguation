import 'dart:typed_data';

import 'package:e_commerce_customer/feature/profile/domain/entities/client_profile.dart';
import 'package:e_commerce_customer/feature/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ClientProfile> call({
    required String name,
    required String email,
    required String phone,
    required String? address,
    required double? latitude,
    required double? longitude,
    Uint8List? pictureBytes,
    String? pictureFileName,
  }) {
    return _repository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      pictureBytes: pictureBytes,
      pictureFileName: pictureFileName,
    );
  }
}
