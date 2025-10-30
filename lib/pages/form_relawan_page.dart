
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormRelawanPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? data;

  const FormRelawanPage({super.key, this.id, this.data});

  @override
  State<FormRelawanPage> createState() => _FormRelawanPageState();
}

class _FormRelawanPageState extends State<FormRelawanPage> {
  final _firestore = FirebaseFirestore.instance;
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _telepon = TextEditingController();
  final _alamat = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _nama.text = widget.data!['nama'] ?? '';
      _email.text = widget.data!['email'] ?? '';
      _telepon.text = widget.data!['telepon'] ?? '';
      _alamat.text = widget.data!['alamat'] ?? '';
    }
  }

  Future<void> _simpan() async {
    var data = {
      'nama': _nama.text,
      'email': _email.text,
      'telepon': _telepon.text,
      'alamat': _alamat.text,
    };

    if (widget.id == null) {
      await _firestore.collection('relawan').add(data);
    } else {
      await _firestore.collection('relawan').doc(widget.id).update(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data relawan disimpan.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Tambah Relawan' : 'Edit Relawan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nama, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _telepon, decoration: const InputDecoration(labelText: 'Telepon')),
            TextField(controller: _alamat, decoration: const InputDecoration(labelText: 'Alamat')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

