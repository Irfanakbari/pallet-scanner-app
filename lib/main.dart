import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import this if you want to use Hive with Flutter
import 'package:palestine_first_run/palestine_first_run.dart';
import 'package:pallet_vuteq/screen/homepage.dart';
import 'package:pallet_vuteq/screen/ip_change.dart';
import 'package:pallet_vuteq/screen/login.dart';

import 'model/history_entry.dart';

void main() {
  Hive
    ..initFlutter()
    ..registerAdapter(HistoryEntryAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  static const storage = FlutterSecureStorage();
  RxBool isLogin = false.obs;
  RxBool isFirst = true.obs;

  Future<void> _checkLogin() async {
    isFirst.value = await PalFirstRun.isFirstRun();
    var token = await storage.read(key: "@vuteq-token");
    if (token != null) {
      isLogin.value = true;
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    // First time (true), then (false)
    return GetMaterialApp(
        title: 'Pallet Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Obx(() => EasySplashScreen(
              logo: Image.asset(
                'assets/images/logo.png',
                width: 300,
              ),
              title: const Text(
                "Pallet Management",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.grey.shade400,
              showLoader: true,
              loadingText: const Text("Loading..."),
              navigator: isFirst.value
                  ? const IpChange()
                  : isLogin.value
                      ? const MyHomePage()
                      : const Login(),
              durationInSeconds: 2,
            )));
  }
}
