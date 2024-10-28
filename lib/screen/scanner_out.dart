import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:newlandscanner/newlandscanner.dart';
import 'package:status_alert/status_alert.dart';

import '../controller/global_controller.dart';

class ScannerOut extends StatefulWidget {
  const ScannerOut({Key? key}) : super(key: key);

  @override
  State<ScannerOut> createState() => _ScannerOutState();
}

class _ScannerOutState extends State<ScannerOut> {
  final storage = const FlutterSecureStorage();
  final GlobalController globalController = Get.find();
  final dio = Dio();
  RxString qrCode = "-".obs;
  RxString actPart = "-".obs;
  RxList riwayat = [].obs;
  RxList destination = [].obs;
  String? selectedValue;
  RxBool isSubmitDisabled = true.obs;

  @override
  void initState() {
    super.initState();
    Newlandscanner.listenForBarcodes.listen((event) {
      if (qrCode.value != '-'){
        actPart.value = event.barcodeData;
      } else {
        qrCode.value = event.barcodeData;
        getDestination();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    riwayat.clear();
  }

  void showAlert(String title, String subtitle, Color backgroundColor) {
    if (mounted) {
      StatusAlert.show(
        context,
        duration: const Duration(seconds: 2),
        title: title,
        subtitle: subtitle,
        backgroundColor: backgroundColor,
        titleOptions: StatusAlertTextConfiguration(
          style: const TextStyle(color: Colors.white),
        ),
        subtitleOptions: StatusAlertTextConfiguration(
          style: const TextStyle(color: Colors.white),
        ),
        configuration: const IconConfiguration(
          icon: Icons.error,
          color: Colors.white,
        ),
      );
    }
  }

  void showSuccessAlert(String title, String subtitle, Color backgroundColor) {
    if (mounted) {
      StatusAlert.show(
        context,
        duration: const Duration(seconds: 2),
        title: title,
        subtitle: subtitle,
        backgroundColor: backgroundColor,
        titleOptions: StatusAlertTextConfiguration(
          style: const TextStyle(color: Colors.white),
        ),
        subtitleOptions: StatusAlertTextConfiguration(
          style: const TextStyle(color: Colors.white),
        ),
        configuration: const IconConfiguration(
          icon: Icons.done,
          color: Colors.white,
        ),
      );
    }
  }

  Future<void> getDestination() async {
    context.loaderOverlay.show();

    final cookie = await storage.read(
        key: '@vuteq-token');
    print(cookie);
    final headers = {
      'Authorization': 'Bearer $cookie',
    };
    try {
      final response =
          await dio.get('http://10.10.10.10:4000/destinations?qr=${qrCode.value}',
              options: Options(
                headers: headers,
                receiveTimeout: const Duration(milliseconds: 5000),
                sendTimeout: const Duration(milliseconds: 5000),
              ));
      destination.value = response.data['data'];
      if (destination.isNotEmpty) {
        selectedValue = destination[0]['name'];
      }
    } on DioException catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Gagal Mengambil Data Destinasi',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isSubmitDisabled.value = false;
      context.loaderOverlay.hide();
    }
  }

  Future<void> submitData() async {
    context.loaderOverlay.show();
    final cookie = await storage.read(
        key: '@vuteq-token');
    final headers = {
      'Authorization': 'Bearer $cookie',
    };
    final Map<String, dynamic> postData = {
      'kode': qrCode.value,
      'destination': selectedValue,
      "act_part": actPart.value
    };

    try {
      final response = await dio.post('http://10.10.10.10:4000/histories',
          data: postData,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(milliseconds: 5000),
            sendTimeout: const Duration(milliseconds: 5000),
          ));

      riwayat.add({"qr": qrCode.value, "date": DateTime.now()});

      Fluttertoast.showToast(
        msg: response.data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } on DioException catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: e.response?.data['message'] ?? 'Kesalahan Jaringan/Server',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      qrCode.value = '-';
      actPart.value = '-';
      selectedValue = null;
      destination.clear();

      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Scanner Keluar Pallet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.grey,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Obx(
                    () => Text(
                      qrCode.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Actual Part Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.grey,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Obx(
                        () => Text(
                      actPart.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
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
                //         if (qrCode.value != '-'){
                //           actPart.value = res;
                //         } else {
                //           qrCode.value = res;
                //           getDestination();
                //         }
                //       }
                //     });
                //   },
                //   child: const Text('Open Scanner'),
                // ),
                if (destination.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destinasi:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.black, // Ubah warna teks jika diperlukan
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButton(
                          isExpanded: true,
                          value: selectedValue ??
                              destination[0][
                                  'name'], // Set the default value to the first item's name
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                          items: destination
                              .map<DropdownMenuItem>(
                                (item) => DropdownMenuItem(
                                  value: item['name'],
                                  child: Text(item['name']),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
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
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: (isSubmitDisabled.value && actPart.value == '-')
                      ? null
                      : () async {
                    await submitData();
                  },
                  child: Container(
                    width: double.infinity,
                    color: (isSubmitDisabled.value && actPart.value == '-') ? Colors.grey : Colors.red,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
