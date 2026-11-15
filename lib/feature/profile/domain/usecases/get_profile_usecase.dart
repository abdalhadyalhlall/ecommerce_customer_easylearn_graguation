import 'package:e_commerce_customer/feature/profile/domain/entities/client_profile.dart';
import 'package:e_commerce_customer/feature/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<ClientProfile> call() => _repository.getProfile();

  Future<ClientProfile?> getCached() => _repository.getCachedProfile();
}
