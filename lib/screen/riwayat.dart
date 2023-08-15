import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/global_controller.dart';

class Riwayat extends StatefulWidget {
  const Riwayat({Key? key}) : super(key: key);

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final storage = const FlutterSecureStorage();
  final GlobalController globalController =
      Get.find(); // Inisialisasi controller
  final dio = Dio();
  RxList riwayat = [].obs;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    riwayat.clear();
  }

  @override
  void initState() {
    super.initState();
    // Load the data from the Hive database when the widget initializes
    loadHistoryEntries();
  }

  Future<void> loadHistoryEntries() async {
    final cookie = globalController.token;

    // Buat header cookie untuk permintaan HTTP
    final headers = {
      'Cookie': 'vuteq-token=$cookie',
    };
    try {
      // Get the list of HistoryEntry objects from the Hive database
      final base = await storage.read(key: '@vuteq-ip');
      final response = await dio.get('http://$base/api/history/operator',
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(milliseconds: 5000),
            sendTimeout: const Duration(milliseconds: 5000),
          ));
      riwayat.clear(); // Clear the existing list
      riwayat
          .addAll(response.data['data']); // Add the new entries to the RxList
    } catch (e) {
      // Handle any potential errors, e.g., when the database is not open
      Fluttertoast.showToast(
        msg: 'Kesalahan Memuat Data',
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
                      'Riwayat Scan Hari Ini',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
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
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Time')),
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
                                width: 30, // Lebar sel
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: 135,
                                alignment: Alignment
                                    .centerLeft, // Posisi isi sel di tengah kiri
                                child: Text(
                                  riwayat[index]['id_pallet'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            DataCell(
                              // Added the 'Status' cell
                              Text(
                                riwayat[index][
                                    'status'], // Replace this with the actual status data
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                child: Text(
                                  DateFormat('HH:mm:ss').format(DateTime.parse(
                                      riwayat[index]['timestamp'])),
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
                ],
              ),
            ),
          ),
        ));
  }
}
