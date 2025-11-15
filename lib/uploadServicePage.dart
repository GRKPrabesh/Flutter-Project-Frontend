import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:securityservice/routes.dart';

class ServiceUploadPage extends StatefulWidget {
  const ServiceUploadPage({super.key});

  @override
  State<ServiceUploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<ServiceUploadPage> {
  PlatformFile? _file;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _file = result.files.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Upload Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: _file == null
                    ? const Text('No file selected')
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insert_drive_file, size: 36, color: Colors.black54),
                          const SizedBox(height: 8),
                          Text(
                            _file!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text('${(_file!.size / 1024).toStringAsFixed(1)} KB',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_file == null ? 'Choose File' : 'Choose Another File'),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  if (_file == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please choose a file to upload')),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${_file!.name}')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoute.loginPageRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'SUBMIT REGISTRATION',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
