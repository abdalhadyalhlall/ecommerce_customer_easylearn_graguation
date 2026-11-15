import 'package:e_commerce_customer/feature/auth/domain/entities/register_entity.dart';
import 'package:e_commerce_customer/feature/auth/domain/repositories/auth_repo.dart';

class RegisterUseCase {
  final AuthRepo _authRepo;

  RegisterUseCase(this._authRepo);

  Future<String> call(RegisterEntity entity) async {
    return _authRepo.register(entity);
  }
}
