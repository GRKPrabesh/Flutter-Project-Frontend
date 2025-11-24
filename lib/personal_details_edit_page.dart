import 'package:flutter/material.dart';
import 'api/auth_api.dart';
import 'api/auth_state.dart';

class PersonalDetailsEditPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const PersonalDetailsEditPage({super.key, required this.initialData});

  @override
  State<PersonalDetailsEditPage> createState() => _PersonalDetailsEditPageState();
}

class _PersonalDetailsEditPageState extends State<PersonalDetailsEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyNameController;
  late TextEditingController _addressController;
  final _authApi = AuthApi();
  bool _isLoading = false;
  bool _isFetchingData = false;
  Map<String, dynamic> _profileData = {};
  bool get _isOrganization => _profileData['role']?.toString() == 'org';

  @override
  void initState() {
    super.initState();
    _profileData = widget.initialData;
    _initializeControllers();
    // If initial data is empty or missing key fields, fetch from API
    if (_profileData.isEmpty || _profileData['email'] == null) {
      _fetchProfileData();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _profileData['name']?.toString() ?? '');
    _emailController = TextEditingController(text: _profileData['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: _profileData['phone']?.toString() ?? '');
    
    // Organization-specific fields
    final orgData = _profileData['organization'] as Map<String, dynamic>?;
    _companyNameController = TextEditingController(
      text: orgData?['companyName']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: orgData?['address']?.toString() ?? '',
    );
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isFetchingData = true);
    try {
      final data = await _authApi.getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isFetchingData = false;
        });
        // Update controllers with fresh data
        _nameController.text = data['name']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _phoneController.text = data['phone']?.toString() ?? '';
        
        final orgData = data['organization'] as Map<String, dynamic>?;
        if (orgData != null) {
          _companyNameController.text = orgData['companyName']?.toString() ?? '';
          _addressController.text = orgData['address']?.toString() ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authApi.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _isOrganization ? _companyNameController.text.trim() : null,
        address: _isOrganization ? _addressController.text.trim() : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personal Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _isOrganization ? 'Owner/Contact Name' : 'Full Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            // Organization-specific fields
            if (_isOrganization) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Organization Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Company Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter company address';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

