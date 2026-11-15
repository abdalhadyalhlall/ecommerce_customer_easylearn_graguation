import 'dart:async';

import 'package:clean_arch_session/core/routes/routes.dart';
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
        Navigator.pushReplacementNamed(context, Routes.login);
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
          'assets/icon/easy_shop.jfif',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
