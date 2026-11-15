import 'package:e_commerce_customer/feature/auth/domain/repositories/auth_repo.dart';

class LogoutUseCase {
  final AuthRepo _authRepo;

  LogoutUseCase(this._authRepo);

  Future<String> call() {
    return _authRepo.logout();
  }
}
