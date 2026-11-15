import 'package:e_commerce_customer/core/cache/cache_const.dart';
import 'package:e_commerce_customer/core/cache/cache_helper.dart';
import 'package:e_commerce_customer/core/di/dependency_injection.dart';
import 'package:e_commerce_customer/core/routes/routes.dart';
import 'package:e_commerce_customer/e_commerce_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  setupGetIt();
  final token = await CacheHelper.getSecureData(key: CacheConstants.userToken);
  runApp(MyApp(initialRoute: token == null ? Routes.splash : Routes.store));
}
