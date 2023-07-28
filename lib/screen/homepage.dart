import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:pallet_vuteq/screen/login.dart';
import 'package:pallet_vuteq/screen/riwayat.dart';
import 'package:pallet_vuteq/screen/scanner_in.dart';
import 'package:pallet_vuteq/screen/scanner_out.dart';
import 'package:pallet_vuteq/screen/scanner_repair.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final storage = const FlutterSecureStorage();
  final dio = Dio();

  Future<void> _logout() async {
    try {
      final base = await storage.read(key: '@vuteq-ip');
      await dio
          .get('http://$base/api/auth/logout',
              options: Options(
                receiveTimeout: const Duration(milliseconds: 5000),
                sendTimeout: const Duration(milliseconds: 5000),
              ))
          .then((value) async {
        Fluttertoast.showToast(
          msg: "Logout Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await storage.delete(key: "@vuteq-token");
        await Get.off(const Login());
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Logout Gagal",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Column(children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () => Get.to(const ScannerOut()),
                  child: Container(
                    width: Get.width,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .arrow_back, // Ganti dengan ikon yang diinginkan
                            color: Colors.white,
                            size: 24.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan Keluar',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () => Get.to(const ScannerIn()),
                  child: Container(
                    width: Get.width,
                    color: Colors.green,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .arrow_forward, // Ganti dengan ikon yang diinginkan
                            color: Colors.white,
                            size: 24.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan Masuk',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () => Get.to(const ScannerRepair()),
                  child: Container(
                    width: Get.width,
                    color: Colors.orangeAccent,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build, // Ganti dengan ikon yang diinginkan
                            color: Colors.white,
                            size: 24.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan Maintenance',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                InkWell(
                  onTap: () => Get.to(const Riwayat()),
                  child: Container(
                    width: Get.width,
                    color: Colors.blueAccent,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history, // Ganti dengan ikon yang diinginkan
                            color: Colors.white,
                            size: 24.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Riwayat Hari Ini',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              Column(children: [
                ElevatedButton(
                  onPressed: () => Dialogs.materialDialog(
                      msg: 'Apa Kamu Yakin Ingin Logout dari Akun?',
                      title: "Keluar",
                      color: Colors.white,
                      context: context,
                      actions: [
                        IconsOutlineButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          text: 'Batal',
                          iconData: Icons.cancel_outlined,
                          textStyle: const TextStyle(color: Colors.grey),
                          iconColor: Colors.grey,
                        ),
                        IconsButton(
                          onPressed: () {
                            _logout();
                          },
                          text: 'Ya',
                          iconData: Icons.logout,
                          color: Colors.red,
                          textStyle: const TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        ),
                      ]),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Warna tombol 'Scanner Masuk'
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .logout, // Ganti dengan ikon logout yang diinginkan
                        size: 20.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8), // Jarak antara ikon dan teks
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary:
                        Colors.blueAccent, // Warna tombol 'Ganti IP Server'
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings, // Ganti dengan ikon Settings
                        size: 20.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8), // Jarak antara ikon dan teks
                      Text(
                        'IP Setting',
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BasicDialogAlert(
          title: const Text("Alamat IP Server"),
          content: TextFormField(
            decoration: const InputDecoration(
              hintText: "Masukkan IP Disini",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Warna tombol tutup dialog
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Batal",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Warna tombol OK
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Simpan",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}