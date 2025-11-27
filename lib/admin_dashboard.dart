import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'services/app_user_repository.dart';
import 'routes.dart';
import 'api/admin_api.dart';
import 'api/service_api.dart';
import 'models/org.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final repo = AppUserRepository.instance;
  final _adminApi = AdminApi();
  final _serviceApi = ServiceApi();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Admin Control Room',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
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
                                color: Colors.red.withOpacity(0.3),
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoute.loginPageRoute,
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1E88E5),
          indicatorWeight: 3,
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
            Tab(icon: Icon(Icons.business_rounded), text: 'Organizations'),
            Tab(icon: Icon(Icons.shield_rounded), text: 'Guards'),
            Tab(icon: Icon(Icons.shopping_cart_rounded), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverview(context),
          _buildOrganizations(context),
          _buildGuards(context),
          _buildOrders(context),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    final seekers = repo.seekers;
    final orgs = repo.organizationsUsers;
    final cards = [
      _StatCard(
        label: 'Guard Seekers',
        value: seekers.length.toString().padLeft(2, '0'),
        icon: Icons.people_alt,
        color: Colors.blueAccent,
      ),
      _StatCard(
        label: 'Organizations',
        value: orgs.length.toString().padLeft(2, '0'),
        icon: Icons.apartment,
        color: Colors.purpleAccent,
      ),
      _StatCard(
        label: 'Available Guards',
        value: repo.guards.length.toString().padLeft(2, '0'),
        icon: Icons.security,
        color: Colors.teal,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards,
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Registrations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...seekers
            .map(
              (user) => _UserTile(
                title: user.displayName,
                subtitle: user.emailOrUsername,
                role: 'Guard Seeker',
                icon: Icons.person,
                color: Colors.blue.shade50,
              ),
            )
            .take(5),
        ...orgs
            .map(
              (user) => _UserTile(
                title: user.displayName,
                subtitle: user.meta['address'] ?? '',
                role: 'Organization',
                icon: Icons.business,
                color: Colors.purple.shade50,
              ),
            )
            .take(5),
      ],
    );
  }

  Widget _buildOrganizations(BuildContext context) {
    return FutureBuilder<List<Org>>(
      future: _serviceApi.fetchOrgs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orgs = snapshot.data ?? [];
        if (orgs.isEmpty) {
          return const Center(child: Text('No organizations registered yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: orgs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final org = orgs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.business_rounded, color: Colors.white, size: 28),
                ),
                title: Text(
                  org.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (org.address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  org.address,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (org.phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  org.phone,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (org.email.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.email_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                org.email,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'View Guards') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _OrgGuardsViewPage(orgId: org.id, orgName: org.name),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$value for ${org.name}')),
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'View Guards', child: Text('View Guards')),
                    PopupMenuItem(value: 'Approve', child: Text('Approve')),
                    PopupMenuItem(value: 'Suspend', child: Text('Suspend')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuards(BuildContext context) {
    return FutureBuilder<List<Org>>(
      future: _serviceApi.fetchOrgs(),
      builder: (context, orgSnapshot) {
        if (orgSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (orgSnapshot.hasError) {
          return Center(child: Text('Error: ${orgSnapshot.error}'));
        }
        final orgs = orgSnapshot.data ?? [];
        if (orgs.isEmpty) {
          return const Center(child: Text('No organizations found'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orgs.length,
          itemBuilder: (context, index) {
            final org = orgs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                ),
                title: Text(
                  org.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'View guards for ${org.name}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _adminApi.fetchOrgStaff(org.id),
                    builder: (context, staffSnapshot) {
                      if (staffSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (staffSnapshot.hasError) {
                        final errorMsg = staffSnapshot.error.toString();
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Error loading guards',
                                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                errorMsg.contains('404') 
                                    ? 'No guards found for this organization'
                                    : errorMsg,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      final guards = staffSnapshot.data ?? [];
                      if (guards.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No guards found for this organization'),
                        );
                      }
                      return Column(
                        children: guards.map((guard) => ListTile(
                          leading: const Icon(Icons.shield),
                          title: Text(guard['name']?.toString() ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (guard['phone'] != null) 
                                Text('Phone: ${guard['phone']}'),
                              if (guard['email'] != null) 
                                Text('Email: ${guard['email']}'),
                              if (guard['experience'] != null) 
                                Text('Experience: ${guard['experience']}'),
                              Text(
                                'Status: ${guard['status'] ?? 'active'}',
                                style: TextStyle(
                                  color: guard['status'] == 'active' 
                                      ? Colors.green 
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrders(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminApi.fetchAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            final serviceName = order['serviceId']?['name']?.toString() ?? 'Unknown';
            final orgName = order['organizationId']?['companyName']?.toString() ?? 'Unknown';
            final clientName = order['userId']?['name']?.toString() ?? 'Unknown';
            final clientEmail = order['userId']?['email']?.toString() ?? '';
            final status = order['status']?.toString() ?? 'pending';
            final assignedGuard = order['assignedStaffId'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.business_rounded, size: 14, color: Colors.blue.shade700),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    orgName,
                                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_rounded, size: 14, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    clientName,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (clientEmail.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.email_rounded, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      clientEmail,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: status == 'confirmed'
                              ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])
                              : status == 'completed'
                                  ? const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF1565C0)])
                                  : const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFF7931E)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (status == 'confirmed'
                                      ? Colors.green
                                      : status == 'completed'
                                          ? Colors.blue
                                          : Colors.orange)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (assignedGuard != null) ...[
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade50, Colors.teal.shade100.withOpacity(0.5)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.teal.shade200, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigned Guard',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.teal.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    assignedGuard['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.42,
      height: 150,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgGuardsViewPage extends StatelessWidget {
  final String orgId;
  final String orgName;

  const _OrgGuardsViewPage({required this.orgId, required this.orgName});

  @override
  Widget build(BuildContext context) {
    final adminApi = AdminApi();
    return Scaffold(
      appBar: AppBar(title: Text('Guards - $orgName')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adminApi.fetchOrgStaff(orgId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final guards = snapshot.data ?? [];
          if (guards.isEmpty) {
            return const Center(child: Text('No guards found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: guards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final guard = guards[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.shield),
                  title: Text(guard['name']?.toString() ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (guard['phone'] != null) Text('Phone: ${guard['phone']}'),
                      if (guard['email'] != null) Text('Email: ${guard['email']}'),
                      if (guard['experience'] != null) Text('Experience: ${guard['experience']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String role;
  final IconData icon;
  final Color color;

  const _UserTile({
    required this.title,
    required this.subtitle,
    required this.role,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

