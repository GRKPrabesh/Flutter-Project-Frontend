import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'routes.dart';
import 'services/app_user_repository.dart';

class SecondPage extends StatefulWidget {
  final String submitLabel;
  final UserRole role;

  const SecondPage({
    super.key,
    this.submitLabel = 'REGISTER',
    this.role = UserRole.seeker,
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _phoneNumber = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Complete account setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                label: 'First Name',
                controller: _firstName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Last Name',
                controller: _lastName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter email' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Password',
                controller: _password,
                obscureText: true,
                validator: (value) => (value == null || value.length < 6)
                    ? 'Min 6 characters'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Confirm Password',
                controller: _confirmPassword,
                obscureText: true,
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Phone Number',
                controller: _phoneNumber,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.length < 7 ? 'Enter phone' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.submitLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator ??
              (value) => value == null || value.trim().isEmpty
                  ? 'Required'
                  : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final repo = AppUserRepository.instance;
    try {
      repo.registerSeeker(
        email: _email.text.trim(),
        password: _password.text,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phoneNumber.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please login.')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.loginPageRoute,
        (route) => false,
      );
    } on StateError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
