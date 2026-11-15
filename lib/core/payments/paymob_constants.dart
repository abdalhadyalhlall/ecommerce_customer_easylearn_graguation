abstract final class PaymobConstants {
  static const List<String> paymentUrlKeys = [
    'url',
    'payment_url',
    'iframe_url',
    'redirect_url',
    'checkout_url',
  ];

  static const List<String> nestedResponseKeys = [
    'data',
    'payment',
    'checkout',
  ];

  static String? findPaymentUrl(dynamic value) {
    if (value is! Map) return null;
    for (final key in paymentUrlKeys) {
      final candidate = value[key];
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    for (final key in nestedResponseKeys) {
      final nestedUrl = findPaymentUrl(value[key]);
      if (nestedUrl != null) return nestedUrl;
    }
    return null;
  }

  static bool isPaymentHost(String host) {
    final normalizedHost = host.toLowerCase();
    return normalizedHost == 'paymob.com' ||
        normalizedHost.endsWith('.paymob.com') ||
        normalizedHost == 'paymobsolutions.com' ||
        normalizedHost.endsWith('.paymobsolutions.com');
  }
}
