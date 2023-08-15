import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pallet_vuteq/screen/login.dart';

class IpChange extends StatefulWidget {
  const IpChange({
    Key? key,
  }) : super(key: key);

  @override
  State<IpChange> createState() => _IpChangeState();
}

class _IpChangeState extends State<IpChange> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _controllerIp = TextEditingController();

  @override
  void dispose() {
    _controllerIp.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ip = _controllerIp.text;
    try {
      await storage.write(key: "@vuteq-ip", value: ip);
      Fluttertoast.showToast(
        msg: "IP Berhasil Disimpan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      await Get.off(const Login());
    } catch (e) {
      Fluttertoast.showToast(
        msg: "IP Gagal Disimpan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 150),
            Image.asset(
              'assets/images/logo.png',
              width: 300,
            ),
            const SizedBox(height: 60),
            TextFormField(
              controller: _controllerIp,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: "IP Server",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 60),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(96, 160, 217, 1),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
