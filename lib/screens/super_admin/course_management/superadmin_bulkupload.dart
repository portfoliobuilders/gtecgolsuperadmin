import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';

class superadminbulkuploadPage extends StatefulWidget {
  const superadminbulkuploadPage({Key? key}) : super(key: key);

  @override
  State<superadminbulkuploadPage> createState() => _superadminbulkuploadPageState();
}
class _superadminbulkuploadPageState extends State<superadminbulkuploadPage> {
  List<List<String>> excelData = [];
  bool isFileUploaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
      provider.token; // Fetch token on page load
      provider.SuperAdminfetchallusersProvider(); // Fetch all users
    });
  }

  // Reads the uploaded Excel file and parses data
  void _readExcelBytes(Uint8List bytes) {
    try {
      var excel = Excel.decodeBytes(bytes);
      List<List<String>> data = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          data.add(row.map((cell) => cell?.value.toString() ?? '').toList());
        }
        break;
      }

      setState(() {
        excelData = data;
        isFileUploaded = true; // Set the flag to true after the file is uploaded
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read the Excel file: $e')),
      );
    }
  }

  // Handles file upload and processes Excel data
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      _readExcelBytes(fileBytes); // Load and parse the file
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick a file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperAdminauthprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadFile,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                if (excelData.isNotEmpty && isFileUploaded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Preview of Uploaded Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: excelData.first
                          .map((header) => DataColumn(label: Text(header)))
                          .toList(),
                      rows: excelData
                          .skip(1)
                          .map(
                            (row) => DataRow(
                              cells: row
                                  .map((cell) => DataCell(Text(cell)))
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (excelData.isNotEmpty && excelData.length > 1) {
                        // Prepare users list from Excel data
                        List<Map<String, dynamic>> users = [];
                        for (var i = 1; i < excelData.length; i++) {
                          var row = excelData[i];
                          users.add({
                            "name": row[0],
                            "email": row[1],
                            "role": row[2],
                            "password": row[3],
                            "phoneNumber": row[4],
                          });
                        }

                        // Check if users list is empty
                        if (users.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No users data found to approve.')),
                          );
                          return;
                        }

                        // Print the users data to the terminal
                        print("Users Data: $users");

                        try {
                          // Call provider method to create users
                          await provider.SuperAdmincreateUsers(users);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Users successfully created.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to create users: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Approve'),
                  )
                ] 
              ],
            ),
    );
  }
}