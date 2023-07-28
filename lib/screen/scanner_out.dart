import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:newlandscanner/newlandscanner.dart';
import 'package:path_provider/path_provider.dart';

import '../model/history_entry.dart';

class ScannerOut extends StatefulWidget {
  const ScannerOut({Key? key}) : super(key: key);

  @override
  State<ScannerOut> createState() => _ScannerOutState();
}

class _ScannerOutState extends State<ScannerOut> {
  final storage = const FlutterSecureStorage();
  final dio = Dio();
  RxString qrCode = "-".obs;
  RxList riwayat = [].obs;
  RxBool isSubmitDisabled = true.obs;

  @override
  void initState() {
    super.initState();
    Newlandscanner.listenForBarcodes.listen((event) {
      qrCode.value = event.barcodeData;
      isSubmitDisabled.value = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    riwayat.clear();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> submitData() async {
      context.loaderOverlay.show();
      // Ambil cookie dari Flutter Secure Storage
      final cookie = await storage.read(
          key: '@vuteq-token'); // Ubah dengan key cookie yang sesuai

      // Buat header cookie untuk permintaan HTTP
      final headers = {
        'Cookie': cookie != null ? '@vuteq-token=$cookie' : '',
      };

      final Map<String, dynamic> postData = {
        'kode': qrCode.value,
      };

      try {
        final base = await storage.read(key: '@vuteq-ip');
        final response = await dio.post('http://$base/api/history',
            data: postData,
            options: Options(
              headers: headers,
              receiveTimeout: const Duration(milliseconds: 5000),
              sendTimeout: const Duration(milliseconds: 5000),
            ));

        riwayat.add({"qr": qrCode.value, "date": DateTime.now()});
        final appDocumentDir = await getApplicationDocumentsDirectory();

        final hiveBox =
            await Hive.openBox('history_entries', path: appDocumentDir.path);

        // Save to Hive database
        final entry = HistoryEntry(
            qr: qrCode.value, date: DateTime.now(), status: 'Keluar');
        await hiveBox.add(entry);

        Fluttertoast.showToast(
          msg: response.data['data'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Reset nilai-nilai
        qrCode.value = '-';
      } on DioException catch (e) {
        // Kesalahan jaringan
        Fluttertoast.showToast(
          msg: e.response?.data['data'] ?? 'Kesalahan Jaringan/Server',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        isSubmitDisabled.value = true;
      }
    }

    return LoaderOverlay(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            // appBar: AppBar(title: const Text('Scanner Keluar')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Obx(
                  () => Column(
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Scanner Keluar Pallet',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Container(
                        color: Colors.grey,
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                            child: Obx(
                          () => Text(
                            qrCode.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                            child: DataTable(
                          columnSpacing: 10, // Mengatur jarak antar kolom
                          headingRowHeight: 40, // Mengatur tinggi baris header
                          dataRowHeight: 60, // Mengatur tinggi baris data
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Pallet ID')),
                            DataColumn(label: Text('Date')),
                          ],
                          rows: List.generate(
                            riwayat.length,
                            (index) => DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                // Mengatur warna latar belakang untuk baris genap dan ganjil
                                return index % 2 == 0
                                    ? Colors.grey[100]!
                                    : Colors.white;
                              }),
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 50, // Lebar sel
                                    child: Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 200, // Lebar sel
                                    alignment: Alignment
                                        .centerLeft, // Posisi isi sel di tengah kiri
                                    child: Text(
                                      riwayat[index]['qr'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    child: Text(
                                      DateFormat('dd-MM-yyyy HH:mm:ss')
                                          .format(riwayat[index]['date']),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                          onTap: isSubmitDisabled.value
                              ? null
                              : () => {
                                    submitData().then(
                                        (value) => context.loaderOverlay.hide())
                                  },
                          child: Container(
                            width: Get.width,
                            color: Colors.red,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    fontSize: 23, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            )));
  }
}
