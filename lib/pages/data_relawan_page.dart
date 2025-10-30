
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_relawan_page.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DataRelawanPage extends StatefulWidget {
  const DataRelawanPage({super.key});

  @override
  State<DataRelawanPage> createState() => _DataRelawanPageState();
}

class _DataRelawanPageState extends State<DataRelawanPage> {
  final CollectionReference _relawan =
      FirebaseFirestore.instance.collection('relawan');

  Future<void> _hapusRelawan(String id) async {
    await _relawan.doc(id).delete();
  }

  Future<void> _eksporExcel() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Relawan'];
      sheet.appendRow(['Nama', 'Email', 'Telepon', 'Alamat']);

      QuerySnapshot snapshot = await _relawan.get();
      for (var doc in snapshot.docs) {
        sheet.appendRow([
          doc['nama'] ?? '',
          doc['email'] ?? '',
          doc['telepon'] ?? '',
          doc['alamat'] ?? '',
        ]);
      }

      Directory dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/Data_Relawan.xlsx";
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File disimpan di: $filePath")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin penyimpanan ditolak.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Relawan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _eksporExcel,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _relawan.orderBy('nama').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              var relawan = data[i];
              return Card(
                child: ListTile(
                  title: Text(relawan['nama'] ?? ''),
                  subtitle: Text(
                    '${relawan['email'] ?? ''}\n${relawan['telepon'] ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormRelawanPage(
                                id: relawan.id,
                                data: relawan.data() as Map<String, dynamic>,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusRelawan(relawan.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormRelawanPage()),
          );
        },
      ),
    );
  }
}

