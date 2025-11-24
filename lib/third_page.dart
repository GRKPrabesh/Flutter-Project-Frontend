import 'package:flutter/material.dart';

import 'routes.dart';

class ThirdPage extends StatefulWidget {
  final String submitLabel;

  const ThirdPage({super.key, this.submitLabel = 'REGISTER BUSINESS'});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _owner = TextEditingController();
  final _address = TextEditingController();
  final _pan = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyName.dispose();
    _owner.dispose();
    _address.dispose();
    _pan.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
                label: 'Company Name',
                controller: _companyName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Owner',
                controller: _owner,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Address',
                controller: _address,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Business Registration / PAN',
                controller: _pan,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Phone Number',
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Organization Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Password',
                controller: _password,
                obscureText: true,
                validator: (value) => (value == null || value.length < 6)
                    ? 'Min 6 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Confirm Password',
                controller: _confirmPassword,
                obscureText: true,
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match' : null,
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

    // Pass collected organization info to the document upload page,
    // where the actual backend registration call will happen.
    final orgData = {
      'companyName': _companyName.text.trim(),
      'owner': _owner.text.trim(),
      'address': _address.text.trim(),
      'panNumber': _pan.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
    };

    Navigator.pushNamed(
      context,
      AppRoute.orgServiceUploadRoute,
      arguments: orgData,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
