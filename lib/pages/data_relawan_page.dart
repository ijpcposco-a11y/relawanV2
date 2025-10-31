
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class DataRelawanPage extends StatefulWidget {
  const DataRelawanPage({Key? key}) : super(key: key);

  @override
  _DataRelawanPageState createState() => _DataRelawanPageState();
}

class _DataRelawanPageState extends State<DataRelawanPage> {
  final CollectionReference relawanCollection =
      FirebaseFirestore.instance.collection('relawan');

  List<Map<String, dynamic>> relawanList = [];

  @override
  void initState() {
    super.initState();
    fetchRelawanData();
  }

  Future<void> fetchRelawanData() async {
    try {
      QuerySnapshot snapshot = await relawanCollection.get();
      setState(() {
        relawanList = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching relawan data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data relawan')),
      );
    }
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Relawan'];

      // Header
      sheetObject.appendRow(['Nama', 'Email', 'No. HP', 'Alamat']);

      // Data
      for (var relawan in relawanList) {
        sheetObject.appendRow([
          relawan['nama'] ?? '',
          relawan['email'] ?? '',
          relawan['noHp'] ?? '',
          relawan['alamat'] ?? '',
        ]);
      }

      // Simpan file
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/data_relawan.xlsx';
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File disimpan di: $filePath')),
      );
    } catch (e) {
      print('Error exporting Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor data')),
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
            icon: const Icon(Icons.download),
            onPressed: exportToExcel,
            tooltip: 'Ekspor ke Excel',
          ),
        ],
      ),
      body: relawanList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: relawanList.length,
              itemBuilder: (context, index) {
                final relawan = relawanList[index];
                return ListTile(
                  title: Text(relawan['nama'] ?? '-'),
                  subtitle: Text(relawan['email'] ?? '-'),
                  trailing: Text(relawan['noHp'] ?? '-'),
                );
              },
            ),
    );
  }
}

