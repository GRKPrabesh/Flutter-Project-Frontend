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
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                email,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
            ),
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
            const SizedBox(height: 32),
            _tile(
              icon: Icons.person_outline_rounded,
              title: 'Personal Details',
              color: const Color(0xFF1E88E5),
              onTap: () async {
                // Ensure we have the latest data before navigating
                Map<String, dynamic> currentData = _profileData ?? {};
                if (currentData.isEmpty || currentData['email'] == null) {
                  try {
                    currentData = await api.getProfile();
                    setState(() => _profileData = currentData);
                  } catch (e) {
                    if (!mounted) return;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
                      );
                    }
                    return;
                  }
                }
                if (!mounted) return;
                if (!context.mounted) return;
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
              icon: Icons.lock_outline_rounded,
              title: 'Password & Security',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
            _tile(
              icon: Icons.color_lens_outlined,
              title: 'Theme',
              color: const Color(0xFFFF6B35),
              onTap: () {},
            ),
            _tile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              color: const Color(0xFF9C27B0),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Logout',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        content: const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (shouldLogout == true && context.mounted) {
                    AuthState.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoute.loginPageRoute,
                      (route) => false,
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF1E88E5),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
