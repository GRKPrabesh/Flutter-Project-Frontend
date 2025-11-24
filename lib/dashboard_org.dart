import 'package:flutter/material.dart';
import 'services_api.dart';
import 'package:securityservice/profile_page.dart';
import 'package:securityservice/routes.dart';
import 'api/service_type_api.dart';
import 'api/org_service_api.dart';
import 'package:securityservice/search_companies_page.dart';
import 'package:securityservice/guards_management_page.dart';
import 'package:securityservice/org_orders_page.dart';

class OrganizationDashboardPage extends StatefulWidget {
  final String? displayName; // organization or username

  const OrganizationDashboardPage({super.key, this.displayName});

  @override
  State<OrganizationDashboardPage> createState() => _OrganizationDashboardPageState();
}

class _OrganizationDashboardPageState extends State<OrganizationDashboardPage> {
  int _tabIndex = 0; // 0: Home, 1: Search, 2: Orders, 3: Guards, 4: Profile
  final _orgServiceApi = OrgServiceApi();
  List<Map<String, dynamic>> _services = [];
  bool _isLoadingServices = false;

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
              icon: Icon(Icons.shield, color: _tabIndex == 3 ? const Color(0xFF1E88E5) : Colors.black54),
              onPressed: () => setState(() => _tabIndex = 3),
              tooltip: 'Guards',
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: _tabIndex == 4 ? const Color(0xFF1E88E5) : Colors.black54),
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

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final services = await _orgServiceApi.fetchServices();
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() => _isLoadingServices = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Widget _buildBody() {
    if (_tabIndex == 1) {
      return const SearchCompaniesPage();
    }
    if (_tabIndex == 2) {
      return const OrgOrdersPage();
    }
    if (_tabIndex == 3) {
      return const GuardsManagementPage();
    }
    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (_isLoadingServices)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoadingServices && _services.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_services.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No services yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Tap the + button to add your first service', 
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._services.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _serviceTile(
                service['name']?.toString() ?? '',
                service['description']?.toString() ?? '',
                'Rs. ${service['price']?.toString() ?? '0'}',
                serviceType: service['serviceTypeId']?['name']?.toString(),
              ),
            )),
        ],
      ),
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

  Widget _serviceTile(String name, String desc, String price, {String? serviceType, String? serviceId}) {
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
                Row(
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    if (serviceType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          serviceType,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
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
    final serviceTypeApi = ServiceTypeApi();
    final orgServiceApi = OrgServiceApi();
    
    String? selectedServiceTypeId;
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();
    final costCtl = TextEditingController();
    final hourlyRateCtl = TextEditingController(text: '300');
    bool isLoading = false;
    bool showAddTypeField = false;
    final newTypeNameCtl = TextEditingController();
    final newTypeDescCtl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Add Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtl,
                        decoration: InputDecoration(
                          labelText: 'Service Name',
                          hintText: 'Enter service name',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Service name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: serviceTypeApi.fetchServiceTypes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading service types: ${snapshot.error}');
                          }
                          final serviceTypes = snapshot.data ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedServiceTypeId,
                                decoration: InputDecoration(
                                  labelText: 'Service Type',
                                  hintText: 'Select service type',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                items: [
                                  ...serviceTypes.map((e) => DropdownMenuItem(
                                    value: e['_id']?.toString() ?? '',
                                    child: Text(e['name']?.toString() ?? ''),
                                  )),
                                  const DropdownMenuItem(
                                    value: '__add_new__',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, size: 18),
                                        SizedBox(width: 8),
                                        Text('Add New Service Type'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    if (v == '__add_new__') {
                                      showAddTypeField = true;
                                      selectedServiceTypeId = null;
                                    } else {
                                      showAddTypeField = false;
                                      selectedServiceTypeId = v;
                                    }
                                  });
                                },
                                validator: (v) => (v == null || v == '__add_new__') ? 'Please select a service type' : null,
                              ),
                              if (showAddTypeField) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: newTypeNameCtl,
                                  decoration: InputDecoration(
                                    labelText: 'New Service Type Name',
                                    hintText: 'Enter new service type',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  validator: showAddTypeField
                                      ? (v) => (v == null || v.trim().isEmpty) ? 'Service type name is required' : null
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: newTypeDescCtl,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'Service Type Description (Optional)',
                                    hintText: 'Enter description',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Service Type'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (newTypeNameCtl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(content: Text('Please enter service type name')),
                                      );
                                      return;
                                    }
                                    try {
                                      setState(() => isLoading = true);
                                      final newType = await serviceTypeApi.createServiceType(
                                        name: newTypeNameCtl.text.trim(),
                                        description: newTypeDescCtl.text.trim().isEmpty 
                                            ? null 
                                            : newTypeDescCtl.text.trim(),
                                      );
                                      setState(() {
                                        selectedServiceTypeId = newType['_id']?.toString();
                                        showAddTypeField = false;
                                        newTypeNameCtl.clear();
                                        newTypeDescCtl.clear();
                                      });
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(content: Text('Service type created successfully')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    } finally {
                                      setState(() => isLoading = false);
                                    }
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter service description',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costCtl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cost',
                          hintText: 'Enter cost (e.g., 1500)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixText: 'Rs. ',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Cost is required';
                          final cost = double.tryParse(v);
                          if (cost == null || cost <= 0) return 'Please enter a valid cost';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: hourlyRateCtl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Hourly Rate (Rs.)',
                          hintText: 'Enter hourly rate (default: 300)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixText: 'Rs. ',
                          helperText: 'Rate per hour for this service',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Hourly rate is required';
                          final rate = double.tryParse(v);
                          if (rate == null || rate <= 0) return 'Please enter a valid hourly rate';
                          return null;
                        },
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
                          onPressed: isLoading ? null : () async {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedServiceTypeId == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Please select a service type')),
                              );
                              return;
                            }
                            try {
                              setState(() => isLoading = true);
                              await orgServiceApi.createService(
                                name: nameCtl.text.trim(),
                                price: double.parse(costCtl.text.trim()),
                                serviceTypeId: selectedServiceTypeId!,
                                description: descCtl.text.trim(),
                                hourlyRate: double.parse(hourlyRateCtl.text.trim()),
                              );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Service "${nameCtl.text}" added successfully')),
                                );
                                // Refresh the services list
                                _loadServices();
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            } finally {
                              if (ctx.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('ADD SERVICE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
