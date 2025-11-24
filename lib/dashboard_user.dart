import 'package:flutter/material.dart';
import 'package:securityservice/search_orgs_page.dart';
import 'package:securityservice/my_bookings_page.dart';
import 'package:securityservice/profile_page.dart';
import 'package:securityservice/routes.dart';
import 'api/service_api.dart';
import 'models/org.dart';

class UserDashboardPage extends StatefulWidget {
  final String? displayName;

  const UserDashboardPage({super.key, this.displayName});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _tabIndex = 0; // 0: Home, 1: Search, 2: Cart, 3: Profile
  final _api = ServiceApi();
  List<Org> _nearbyOrgs = [];
  List<Org> _topOrgs = [];
  bool _isLoadingOrgs = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() => _isLoadingOrgs = true);
    try {
      final orgs = await _api.fetchOrgs();
      setState(() {
        // For now, show first 2 as "Near me" and next 2 as "Top services"
        // In a real app, you'd filter by location/rating
        _nearbyOrgs = orgs.take(2).toList();
        _topOrgs = orgs.skip(2).take(2).toList();
        _isLoadingOrgs = false;
      });
    } catch (e) {
      setState(() => _isLoadingOrgs = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading organizations: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.displayName ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Do you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.loginPageRoute,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 6),
        child: SizedBox(
          height: 58,
          width: 58,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: () {},
            child: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: _tabIndex == 0 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.search, color: _tabIndex == 1 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 1),
            ),
            const SizedBox(width: 24), // space for notch (center SOS)
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: _tabIndex == 2 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 2),
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _tabIndex == 3 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => Navigator.pushNamed(context, AppRoute.profileRoute),
            ),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_tabIndex == 1) return SearchOrgsPage();
    if (_tabIndex == 2) return MyBookingsPage();
    return RefreshIndicator(
      onRefresh: _loadOrganizations,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search service and organization',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          _banner(context, 'OFFER SALES'),
          const SizedBox(height: 16),
          const Text('Near me', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_isLoadingOrgs)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ))
          else if (_nearbyOrgs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No organizations found nearby'),
              ),
            )
          else
            ..._nearbyOrgs.map((org) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _orgCard(context, org),
            )),
          const SizedBox(height: 16),
          const Text('Top services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_isLoadingOrgs)
            const SizedBox.shrink()
          else if (_topOrgs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No top services available'),
              ),
            )
          else
            ..._topOrgs.map((org) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _orgCard(context, org),
            )),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context, String text) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _orgCard(BuildContext context, Org org) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.apartment, color: Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company name
                Text(
                  org.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Location
                if (org.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            org.address,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Phone number
                if (org.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          org.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Email
                if (org.email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            org.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Connect button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11B47A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoute.searchOrgsRoute);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
