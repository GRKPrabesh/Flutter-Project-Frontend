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
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text('Admin Control Room'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content:
                      const Text('Do you want to logout?'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: scheme.primary,
          labelColor: scheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Organizations'),
            Tab(text: 'Guards'),
            Tab(text: 'Orders'),
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
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  child: const Icon(Icons.apartment, color: Colors.indigo),
                ),
                title: Text(org.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (org.address.isNotEmpty) Text(org.address),
                    if (org.phone.isNotEmpty) Text('Phone: ${org.phone}'),
                    if (org.email.isNotEmpty) Text('Email: ${org.email}'),
                  ],
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: const Icon(Icons.apartment, color: Colors.teal),
                ),
                title: Text(org.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('View guards for ${org.name}'),
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
            
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Provider: $orgName',
                                style: TextStyle(color: Colors.blue[700], fontSize: 14),
                              ),
                              Text(
                                'Client: $clientName',
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              if (clientEmail.isNotEmpty)
                                Text(
                                  clientEmail,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'confirmed' 
                                ? Colors.green.shade50 
                                : status == 'completed' 
                                    ? Colors.blue.shade50 
                                    : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: status == 'confirmed' 
                                  ? Colors.green.shade700 
                                  : status == 'completed' 
                                      ? Colors.blue.shade700 
                                      : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (assignedGuard != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield, size: 16, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text(
                              'Guard: ${assignedGuard['name'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
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
      height: 130,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle),
              ],
            ),
          ),
          Chip(
            label: Text(role),
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

