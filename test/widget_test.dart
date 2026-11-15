import 'package:e_commerce_customer/core/di/dependency_injection.dart';
import 'package:e_commerce_customer/core/payments/paymob_constants.dart';
import 'package:e_commerce_customer/core/routes/routes.dart';
import 'package:e_commerce_customer/core/theme/app_theme.dart';
import 'package:e_commerce_customer/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce_customer/feature/auth/presentation/ui/login_screen.dart';
import 'package:e_commerce_customer/feature/auth/presentation/ui/otp_screen.dart';
import 'package:e_commerce_customer/feature/auth/presentation/ui/register_screen.dart';
import 'package:e_commerce_customer/feature/auth/presentation/ui/splash_screen.dart';
import 'package:e_commerce_customer/feature/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce_customer/feature/profile/presentation/ui/screen/edit_profile_screen.dart';
import 'package:e_commerce_customer/feature/profile/presentation/ui/widget/profile_widgets.dart';
import 'package:e_commerce_customer/feature/store/domain/entities/store_entities.dart';
import 'package:e_commerce_customer/feature/store/presentation/cubit/store_cubit.dart';
import 'package:e_commerce_customer/feature/store/presentation/ui/screen/checkout_screen.dart';
import 'package:e_commerce_customer/feature/store/presentation/ui/screen/order_success_screen.dart';
import 'package:e_commerce_customer/feature/store/presentation/ui/screen/product_details_screen.dart';
import 'package:e_commerce_customer/feature/store/presentation/ui/screen/store_screen.dart';
import 'package:e_commerce_customer/e_commerce_customer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  testWidgets('adapts the login screen to compact and tablet sizes', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.devicePixelRatio = 1;

    for (final size in [const Size(320, 568), const Size(768, 1024)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp(initialRoute: Routes.login));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('renders application screens across phone and tablet sizes', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.devicePixelRatio = 1;

    final responsiveScreens = <String, Widget Function()>{
      'login': () => BlocProvider(
        create: (_) => getIt<AuthCubit>(),
        child: const LoginScreen(),
      ),
      'register': () => BlocProvider(
        create: (_) => getIt<AuthCubit>(),
        child: const RegisterScreen(),
      ),
      'OTP': () => BlocProvider(
        create: (_) => getIt<AuthCubit>(),
        child: const OtpScreen(email: 'test@example.com'),
      ),
      'profile editor': () => BlocProvider<ProfileCubit>(
        create: (_) => _ResponsiveProfileCubit(),
        child: const EditProfileScreen(),
      ),
      'product details': () => BlocProvider<StoreCubit>(
        create: (_) => _ResponsiveStoreCubit(),
        child: ProductDetailsScreen(product: _testProduct),
      ),
      'checkout': () => MultiBlocProvider(
        providers: [
          BlocProvider<StoreCubit>(create: (_) => _ResponsiveStoreCubit()),
          BlocProvider<ProfileCubit>(create: (_) => _ResponsiveProfileCubit()),
        ],
        child: const CheckoutScreen(),
      ),
      'order success': () => const OrderSuccessScreen(order: _testOrder),
    };
    final sizes = [
      const Size(320, 568),
      const Size(375, 812),
      const Size(768, 1024),
      const Size(812, 375),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      for (final entry in responsiveScreens.entries) {
        await tester.pumpWidget(_responsiveScreen(entry.value()));
        await tester.pump();

        final exception = tester.takeException();
        if (exception != null) {
          debugPrint(
            exception is FlutterError ? exception.toStringDeep() : '$exception',
          );
        }
        expect(
          exception,
          isNull,
          reason: '${entry.key} overflowed at ${size.width}x${size.height}',
        );
      }

      await tester.pumpWidget(
        _responsiveScreen(
          BlocProvider<AuthCubit>(
            create: (_) => getIt<AuthCubit>(),
            child: const SplashScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'splash at $size');

      await tester.pumpWidget(
        _responsiveScreen(
          MultiBlocProvider(
            providers: [
              BlocProvider<StoreCubit>(create: (_) => _ResponsiveStoreCubit()),
              BlocProvider<ProfileCubit>(
                create: (_) => _ResponsiveProfileCubit(),
              ),
              BlocProvider(create: (_) => getIt<AuthCubit>()),
            ],
            child: const StoreScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'store tabs at $size');
    }
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
    expect(PaymobConstants.isPaymentHost('accept.paymob.com'), isTrue);
    expect(PaymobConstants.isPaymentHost('paymob.com.example.org'), isFalse);
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

const _testProduct = StoreProduct(
  id: 1,
  name: 'Responsive test product',
  slug: 'responsive-test-product',
  description: 'A sample product used to check responsive layouts.',
  price: 99,
  quantity: 3,
);

const _testOrder = StoreOrder(
  id: 1,
  code: 'RESP-1',
  status: 'pending',
  totalPrice: 99,
  address: 'Test address',
  paymentMethod: 'cash',
  items: [],
  createdAt: '2026-01-01',
);

Widget _responsiveScreen(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, _) => MaterialApp(home: home),
  );
}

class _ResponsiveStoreCubit extends StoreCubit {
  _ResponsiveStoreCubit() : super(getIt(), getIt(), getIt(), getIt());

  @override
  Future<void> loadCategories() async {}

  @override
  Future<void> loadProducts({
    String? categorySlug,
    bool refresh = false,
  }) async {}

  @override
  Future<void> loadCart() async {}

  @override
  Future<void> loadFavorites() async {}

  @override
  Future<void> loadOrders() async {}
}

class _ResponsiveProfileCubit extends ProfileCubit {
  _ResponsiveProfileCubit() : super(getIt(), getIt());

  @override
  Future<void> loadProfile() async {}
}
