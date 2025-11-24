import 'package:flutter/material.dart';
import 'api/auth_api.dart';
import 'api/auth_state.dart';
import 'dashboard_org.dart';

class VerifyOtpPage extends StatefulWidget {
  final String? email;
  const VerifyOtpPage({super.key, this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String get email => widget.email ?? AuthState.email ?? '';

  final _api = AuthApi();

  Future<void> _verify() async {
    final code = _otpCtrl.text.trim();
    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter OTP')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.verifyOtp(email: email, otp: code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification successful. Please login.')));
      Navigator.of(context).pop(); // Go back to previous screen (typically login)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _api.resendOtp(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to resend OTP')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('We sent a code to\n$email'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _verify, child: const Text('Verify')),
            TextButton(onPressed: _loading ? null : _resend, child: const Text('Resend OTP')),
          ],
        ),
      ),
    );
  }
}
