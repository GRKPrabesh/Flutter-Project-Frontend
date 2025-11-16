import 'package:flutter/material.dart';
import 'package:securityservice/pages/search_orgs_page.dart';
import 'package:securityservice/pages/my_bookings_page.dart';
import 'package:securityservice/pages/profile_page.dart';
import 'package:securityservice/routes.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _tabIndex = 0; // 0: Home, 1: Search, 2: Cart, 3: Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
              onPressed: () => setState(() => _tabIndex = 3),
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
    if (_tabIndex == 3) return const ProfilePage();
    return ListView(
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
        _orgCard(context, 'Kathmandu Security House', 'Kalimati, Kathmandu', '+977 9876545324', members: 24),
        const SizedBox(height: 16),
        const Text('Top services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _orgCard(context, 'Lalitpur Security House', 'Sanepa, Lalitpur', '+977 9812345678', members: 10),
      ],
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

  Widget _orgCard(BuildContext context, String name, String address, String phone, {required int members}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE8F1FD), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.apartment, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [const Icon(Icons.location_on, size: 14), const SizedBox(width: 4), Expanded(child: Text(address, overflow: TextOverflow.ellipsis))]),
                Row(children: [const Icon(Icons.call, size: 14), const SizedBox(width: 4), Text(phone)]),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.groups_2_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text('$members'),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11B47A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoute.searchOrgsRoute);
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
