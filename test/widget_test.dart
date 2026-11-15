import 'package:clean_arch_session/core/di/dependency_injection.dart';
import 'package:clean_arch_session/core/payments/paymob_constants.dart';
import 'package:clean_arch_session/core/routes/routes.dart';
import 'package:clean_arch_session/core/theme/app_theme.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/login_screen.dart';
import 'package:clean_arch_session/feature/auth/presentation/ui/splash_screen.dart';
import 'package:clean_arch_session/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:clean_arch_session/feature/store/domain/entities/store_entities.dart';
import 'package:clean_arch_session/e_commerce_customer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString:
          'API_BASE_URL=https://easylearn.devawy.com/api\nAPI_KEY=test-key',
    );
    setupGetIt();
  });

  testWidgets('starts on the login screen', (tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: Routes.login));

    expect(find.byType(LoginScreen, skipOffstage: false), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('shows the Easy Shop splash before login', (tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: Routes.splash));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('uses the bundled application font throughout the app', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(initialRoute: Routes.login));

    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'EasyShopSans');
  });

  testWidgets('shows two initials in the profile avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(imageUrl: null, name: 'Ahmed Hassan', radius: 30),
        ),
      ),
    );

    expect(find.text('AH'), findsOneWidget);
  });

  testWidgets('profile menu tiles paint ink on their Material card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: ProfileMenuTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('Paymob responses can expose a nested hosted payment URL', () {
    expect(
      PaymobConstants.findPaymentUrl({
        'data': {
          'payment': {'iframe_url': 'https://accept.paymob.com/checkout/test'},
        },
      }),
      'https://accept.paymob.com/checkout/test',
    );
    expect(
      PaymobConstants.isPaymentHost('accept.paymob.com'),
      isTrue,
    );
    expect(
      PaymobConstants.isPaymentHost('paymob.com.example.org'),
      isFalse,
    );
  });

  test('products preserve visibility and stock state', () {
    const visibleInStock = StoreProduct(
      id: 1,
      name: 'Available',
      slug: 'available',
      description: '',
      price: 10,
      quantity: 2,
    );
    const hiddenProduct = StoreProduct(
      id: 2,
      name: 'Hidden',
      slug: 'hidden',
      description: '',
      price: 10,
      quantity: 2,
      visible: false,
    );
    const soldOutProduct = StoreProduct(
      id: 3,
      name: 'Sold out',
      slug: 'sold-out',
      description: '',
      price: 10,
      quantity: 0,
    );

    expect(visibleInStock.isVisible, isTrue);
    expect(visibleInStock.isInStock, isTrue);
    expect(hiddenProduct.isVisible, isFalse);
    expect(soldOutProduct.isInStock, isFalse);
  });
}
