
import 'package:e_commerce_customer/core/routes/app_router.dart';
import 'package:e_commerce_customer/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'Easy Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter().generateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        ),
      ),
    );
  }
}
