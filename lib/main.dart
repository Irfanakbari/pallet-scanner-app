import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:palestine_first_run/palestine_first_run.dart';
import 'package:pallet_vuteq/screen/homepage.dart';
import 'package:pallet_vuteq/screen/ip_change.dart';
import 'package:pallet_vuteq/screen/login.dart';

import 'controller/global_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  RxBool isLogin = false.obs;
  RxBool isFirst = true.obs;
  final GlobalController globalController =
      Get.put(GlobalController()); // Inisialisasi controller

  Future<void> _checkLogin() async {
    isFirst.value = await PalFirstRun.isFirstRun();
    if (globalController.token != '') {
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
    initializeDateFormatting('id_ID', null);

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
