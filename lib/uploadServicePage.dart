import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api/config.dart';
import 'routes.dart';
import 'verify_otp.dart';

class ServiceUploadPage extends StatefulWidget {
  const ServiceUploadPage({super.key});

  @override
  State<ServiceUploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<ServiceUploadPage> {
  XFile? _file;

  Future<void> _pickFile() async {
    final typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf', 'jpg', 'jpeg', 'png']);
    final picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked != null) setState(() => _file = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Organization registration data passed from ThirdPage
    final orgArgs =
        (ModalRoute.of(context)?.settings.arguments as Map<String, String>?) ??
            const <String, String>{};

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
                          FutureBuilder<int>(
                            future: _file!.length(),
                            builder: (context, snap) => Text(
                              snap.hasData ? '${((snap.data! / 1024)).toStringAsFixed(1)} KB' : '',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
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
                onPressed: () async {
                  if (_file == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please choose a document to upload')),
                    );
                    return;
                  }

                  final email = orgArgs['email'] ?? '';
                  final password = orgArgs['password'] ?? '';
                  final companyName = orgArgs['companyName'] ?? '';
                  final companyAddress = orgArgs['address'] ?? '';
                  final owner = orgArgs['owner'] ?? companyName;
                  final panNumber = orgArgs['panNumber'] ?? '';
                  final phone = orgArgs['phone'] ?? '';

                  if (email.isEmpty ||
                      password.isEmpty ||
                      companyName.isEmpty ||
                      companyAddress.isEmpty ||
                      panNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Missing organization details. Please go back and complete the form.')),
                    );
                    return;
                  }

                  final url =
                      Uri.parse('${AppConfig.baseUrl}/api/auth/register');
                  final body = jsonEncode({
                    "name": owner,
                    "email": email,
                    "password": password,
                    "phone": phone,
                    "role": "org",
                    "companyName": companyName,
                    "companyAddress": companyAddress,
                    "panNumber": panNumber,
                    // For now we just send file name as document reference
                    "docPic": _file!.name,
                  });

                  try {
                    final res = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: body,
                    );

                    if (res.statusCode == 200 || res.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Organization registered. Please verify OTP.')),
                      );
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VerifyOtpPage(email: email),
                        ),
                      );
                    } else {
                      Map<String, dynamic> data = const {};
                      if (res.body.isNotEmpty) {
                        try {
                          data = jsonDecode(res.body) as Map<String, dynamic>;
                        } catch (_) {
                          // ignore JSON parse errors
                        }
                      }
                      final msg =
                          data['message']?.toString() ?? 'Registration failed';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Network error. Please try again.')),
                    );
                  }
                },
                child: const Text(
                  'SUBMIT REGISTRATION',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
