import 'package:flutter/material.dart';
import 'services_api.dart';
import 'package:securityservice/profile_page.dart';
import 'package:securityservice/routes.dart';

class OrganizationDashboardPage extends StatefulWidget {
  final String? displayName; // organization or username

  const OrganizationDashboardPage({super.key, this.displayName});

  @override
  State<OrganizationDashboardPage> createState() => _OrganizationDashboardPageState();
}

class _OrganizationDashboardPageState extends State<OrganizationDashboardPage> {
  int _tabIndex = 0; // 0: Home, 1: Search, 2: Orders, 3: Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: Text('Welcome ! ${widget.displayName ?? 'there'}'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  final scheme = Theme.of(ctx).colorScheme;
                  return AlertDialog(
                    icon: Icon(Icons.logout_rounded, color: scheme.error),
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    actionsAlignment: MainAxisAlignment.end,
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout == true) {
                // Navigate to Login and clear stack
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12),
        child: SizedBox(
          height: 58,
          width: 58,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SOS triggered')),
              );
            },
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
              tooltip: 'Home',
            ),
            IconButton(
              icon: Icon(Icons.search, color: _tabIndex == 1 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 1),
              tooltip: 'Search',
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: Icon(Icons.assignment_outlined, color: _tabIndex == 2 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 2),
              tooltip: 'Orders',
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _tabIndex == 3 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => Navigator.pushNamed(context, AppRoute.profileRoute),
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildBody(),
          // Small '+' FAB above the Profile icon (bottom-right)
          Positioned(
            right: 10,
            bottom: 24, // closer to the Profile icon on BottomAppBar
            child: Transform.scale(
              scale: 0.85,
              child: FloatingActionButton.small(
                heroTag: 'fab_add_service_small',
                backgroundColor: const Color(0xFF1E88E5),
                elevation: 5,
                shape: const StadiumBorder(),
                onPressed: () => _openAddServiceSheet(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search service and organization',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
      );
    }
    if (_tabIndex == 2) {
      return const Center(child: Text('Orders'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _headerCard(),
        const SizedBox(height: 16),
        const Text('Your services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _serviceTile('Guard Patrol', 'Night patrol around premises', 'Rs. 2500 / shift'),
        const SizedBox(height: 8),
        _serviceTile('CCTV Monitoring', '24/7 monitoring and alerting', 'Rs. 1500 / day'),
      ],
    );
  }

  Widget _headerCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [const Color(0xFF1E88E5), const Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Center(
        child: Text(
          'Welcome ! ${widget.displayName ?? 'there'}',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _serviceTile(String name, String desc, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE8F1FD), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.shield_outlined, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddServiceSheet(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String? selectedService;
    final descCtl = TextEditingController();
    final chargeCtl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                FutureBuilder<List<String>>(
                  future: ServicesApi.fetchServiceNames(),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <String>[];
                    return DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: InputDecoration(
                        hintText: 'Select service',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => selectedService = v,
                      validator: (v) => v == null ? 'Please select a service' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter description' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: chargeCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Charge (e.g., 1500)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter charge' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added: ${selectedService ?? ''} - Rs. ${chargeCtl.text}')),
                      );
                    },
                    child: const Text('ADD SERVICE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
