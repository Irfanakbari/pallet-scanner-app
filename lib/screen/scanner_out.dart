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
  RxList riwayat = [].obs;
  RxList destination = [].obs;
  String? selectedValue;
  RxBool isSubmitDisabled = true.obs;

  @override
  void initState() {
    super.initState();
    Newlandscanner.listenForBarcodes.listen((event) {
      qrCode.value = event.barcodeData;
      getDestination();
    });
  }

  @override
  void dispose() {
    super.dispose();
    riwayat.clear();
  }

  Future<void> getDestination() async {
    context.loaderOverlay.show();

    final cookie = globalController.token;
    final headers = {'Cookie': 'vuteq-token=$cookie'};

    try {
      final base = await storage.read(key: '@vuteq-ip');
      final response =
          await dio.get('$base/api/destination/get/${qrCode.value}',
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
    final cookie = globalController.token;
    final headers = {'Cookie': 'vuteq-token=$cookie'};
    final Map<String, dynamic> postData = {
      'kode': qrCode.value,
      'destination': selectedValue
    };

    try {
      final base = await storage.read(key: '@vuteq-ip');
      final response = await dio.post('$base/api/history',
          data: postData,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(milliseconds: 5000),
            sendTimeout: const Duration(milliseconds: 5000),
          ));

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
      selectedValue = null;
      destination.clear();
      isSubmitDisabled.value = true;
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
                //         getDestination();
                //         isSubmitDisabled.value = false;
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
                  onTap: isSubmitDisabled.value
                      ? null
                      : () async {
                          await submitData();
                        },
                  child: Container(
                    width: double.infinity,
                    color: isSubmitDisabled.value ? Colors.grey : Colors.red,
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
