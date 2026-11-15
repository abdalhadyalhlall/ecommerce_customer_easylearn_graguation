import 'package:e_commerce_customer/core/cache/cache_const.dart';
import 'package:e_commerce_customer/core/cache/cache_helper.dart';

class CartCache {
  static Future<void> save(String encodedCart) {
    return CacheHelper.saveSecureData(
      key: CacheConstants.cartItems,
      value: encodedCart,
    );
  }

  static Future<String?> read() {
    return CacheHelper.getSecureData(key: CacheConstants.cartItems);
  }

  static Future<void> clear() {
    return CacheHelper.deleteSecureData(key: CacheConstants.cartItems);
  }
}
