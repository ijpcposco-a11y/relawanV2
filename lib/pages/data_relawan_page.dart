
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart' as perm;

Future<void> _eksporExcel() async {
  var status = await perm.Permission.storage.request();
  if (status.isGranted) {
    var excel = xls.Excel.createExcel();
    var sheet = excel['Relawan'];
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

    Directory dir = await path.getExternalStorageDirectory() ??
        await path.getApplicationDocumentsDirectory();
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

