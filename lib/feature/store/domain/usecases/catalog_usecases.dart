import 'package:e_commerce_customer/feature/store/domain/entities/store_entities.dart';
import 'package:e_commerce_customer/feature/store/domain/repositories/store_repository.dart';

class CatalogUseCases {
  final StoreRepository _repository;

  CatalogUseCases(this._repository);

  Future<List<StoreCategory>> getCategories() {
    return _repository.getCategories();
  }

  Future<List<StoreProduct>> getProducts({String? categorySlug}) {
    return _repository.getProducts(categorySlug: categorySlug);
  }

  Future<StoreProduct> getProductDetails(String slug) {
    return _repository.getProductDetails(slug);
  }
}
