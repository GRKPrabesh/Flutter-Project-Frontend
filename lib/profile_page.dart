import 'package:flutter/material.dart';
import 'api/auth_api.dart';
import 'api/auth_state.dart';
import 'routes.dart';
import 'personal_details_edit_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: const ProfileView());
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final api = AuthApi();
  Map<String, dynamic>? _profileData;
  Future<Map<String, dynamic>>? _profileFuture;

  Future<Map<String, dynamic>> _loadProfile({bool forceRefresh = false}) async {
    // If force refresh is requested, clear cache
    if (forceRefresh) {
      _profileData = null;
      _profileFuture = null;
    }
    
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _profileData != null && _profileData!.isNotEmpty) {
      return _profileData!;
    }
    
    // Use cached future if already loading
    if (_profileFuture != null && !forceRefresh) {
      return _profileFuture!;
    }
    
    // Create new future and cache it
    _profileFuture = api.getProfile().then((data) {
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
      return data;
    }).catchError((e) {
      // Clear future on error so it can be retried
      _profileFuture = null;
      throw e;
    });
    
    return _profileFuture!;
  }

  void _refreshProfile() {
    setState(() {
      _profileData = null;
      _profileFuture = null;
    });
    // Force refresh when manually refreshing
    _loadProfile(forceRefresh: true);
  }

  @override
  void initState() {
    super.initState();
    // Always fetch fresh profile data when navigating to profile page
    _loadProfile(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Use cached future to avoid duplicate calls
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture ?? _loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _profileData == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final errorMsg = snapshot.error.toString();
          final hasToken = AuthState.token != null && AuthState.token!.isNotEmpty;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    errorMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                if (!hasToken) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No authentication token found. Please login again.',
                    style: TextStyle(color: Colors.orange[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _refreshProfile();
                    _loadProfile();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data ?? _profileData ?? {};
        
        // If data is still empty, show a message
        if (data.isEmpty || data['email'] == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Loading profile data...'),
              ],
            ),
          );
        }
        // Data is already cached in _loadProfile
        final name = (data['name'] ?? data['fullName'] ?? 'User').toString();
        final email = (data['email'] ?? AuthState.email ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final role = data['role']?.toString() ?? '';
        final isOrg = role == 'org';
        final orgData = data['organization'] as Map<String, dynamic>?;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
            Center(child: Text(email, style: const TextStyle(color: Colors.black54))),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            if (isOrg && orgData != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  orgData['companyName']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                ),
              ),
              if (orgData['address']?.toString().isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          orgData['address']?.toString() ?? '',
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            _tile(
              icon: Icons.person_outline,
              title: 'Personal Details',
              onTap: () async {
                // Ensure we have the latest data before navigating
                Map<String, dynamic> currentData = _profileData ?? {};
                if (currentData.isEmpty || currentData['email'] == null) {
                  try {
                    currentData = await api.getProfile();
                    setState(() => _profileData = currentData);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
                    );
                    return;
                  }
                }
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalDetailsEditPage(initialData: currentData),
                  ),
                );
                if (result == true && mounted) {
                  // Reload profile after successful update
                  _refreshProfile();
                  _loadProfile();
                }
              },
            ),
            _tile(
              icon: Icons.lock_outline,
              title: 'Password & Security',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
            _tile(icon: Icons.color_lens_outlined, title: 'Theme', onTap: () {}),
            _tile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                AuthState.clear();
                Navigator.pushNamedAndRemoveUntil(context, AppRoute.loginPageRoute, (route) => false);
              },
              child: const Text('Logout'),
            )
          ],
        );
      },
    );
  }

  Widget _tile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(children: [
      ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
      const Divider(height: 1)
    ]);
  }
}
