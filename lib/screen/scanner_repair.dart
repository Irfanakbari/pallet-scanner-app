import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:newlandscanner/newlandscanner.dart';

import '../controller/global_controller.dart';

class ScannerRepair extends StatefulWidget {
  const ScannerRepair({Key? key}) : super(key: key);

  @override
  State<ScannerRepair> createState() => _ScannerRepairState();
}

class _ScannerRepairState extends State<ScannerRepair> {
  final storage = const FlutterSecureStorage();
  final GlobalController globalController =
      Get.find(); // Inisialisasi controller
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
    super.dispose();
    riwayat.clear();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> submitData() async {
      context.loaderOverlay.show();
      final cookie = globalController.token;

      final headers = {
        'Cookie': 'vuteq-token=$cookie',
      };

      final Map<String, dynamic> postData = {
        'kode': qrCode.value,
      };

      try {
        final base = await storage.read(key: '@vuteq-ip');
        final response = await dio.post(
          '$base/api/repairs',
          data: postData,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(milliseconds: 5000),
            sendTimeout: const Duration(milliseconds: 5000),
          ),
        );

        riwayat.add({"qr": qrCode.value, "date": DateTime.now()});

        Fluttertoast.showToast(
          msg: response.data['data'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } on DioException catch (e) {
        Fluttertoast.showToast(
          msg: e.response?.data['data'] ?? 'Kesalahan Jaringan/Server',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        qrCode.value = '-';
        isSubmitDisabled.value = true;
        context.loaderOverlay.hide();
      }
    }

    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Scanner Maintenance Pallet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () async {
                //     var res = await Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) =>
                //               const SimpleBarcodeScannerPage(),
                //         ));
                //     setState(() {
                //       if (res is String) {
                //         qrCode.value = res;
                //         isSubmitDisabled.value = false;
                //       }
                //     });
                //   },
                //   child: const Text('Open Scanner'),
                // ),
                const SizedBox(height: 20),
                Expanded(
                    child: Obx(
                  () => SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 10,
                      headingRowHeight: 40,
                      dataRowHeight: 60,
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Pallet ID')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: List.generate(
                        riwayat.length,
                        (index) => DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return index % 2 == 0
                                ? Colors.grey[100]!
                                : Colors.white;
                          }),
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 50,
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 200,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  riwayat[index]['qr'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                child: Text(
                                  DateFormat('HH:mm:ss')
                                      .format(riwayat[index]['date']),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                Obx(
                  () => InkWell(
                    onTap: isSubmitDisabled.value
                        ? null
                        : () async {
                            await submitData();
                          },
                    child: Container(
                      width: Get.width,
                      color: isSubmitDisabled.value ? Colors.grey : Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 23, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
