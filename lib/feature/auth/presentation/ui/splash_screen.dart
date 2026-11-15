import 'dart:async';

import 'package:e_commerce_customer/core/assets/app_assets.dart';
import 'package:e_commerce_customer/core/helpers/context_extensions.dart';
import 'package:e_commerce_customer/core/routes/routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        context.pushReplacementNamed(Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF3),
      body: SizedBox.expand(
        child: Image.asset(
          AppAssets.easyShop,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
