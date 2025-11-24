import 'package:flutter/material.dart';
import 'api/staff_api.dart';

class GuardsManagementPage extends StatefulWidget {
  const GuardsManagementPage({super.key});

  @override
  State<GuardsManagementPage> createState() => _GuardsManagementPageState();
}

class _GuardsManagementPageState extends State<GuardsManagementPage> {
  final _staffApi = StaffApi();
  List<Map<String, dynamic>> _guards = [];
  List<Map<String, dynamic>> _onDutyGuards = [];
  List<Map<String, dynamic>> _freeGuards = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // 'all', 'free', 'onDuty'

  @override
  void initState() {
    super.initState();
    _loadGuards();
  }

  Future<void> _loadGuards() async {
    setState(() => _isLoading = true);
    try {
      final guards = await _staffApi.fetchStaff();
      setState(() {
        _guards = guards;
        _freeGuards = guards.where((g) => 
          (g['status']?.toString() == 'active' || g['status'] == null) &&
          (g['dutyStatus']?.toString() != 'onDuty' || g['dutyStatus'] == null)
        ).toList();
        _onDutyGuards = guards.where((g) => 
          g['dutyStatus']?.toString() == 'onDuty'
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading guards: ${e.toString()}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _displayGuards {
    switch (_filterStatus) {
      case 'free':
        return _freeGuards;
      case 'onDuty':
        return _onDutyGuards;
      default:
        return _guards;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guards Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGuards,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'all');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Free (${_freeGuards.length})'),
                    selected: _filterStatus == 'free',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'free');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('On Duty (${_onDutyGuards.length})'),
                    selected: _filterStatus == 'onDuty',
                    onSelected: (selected) {
                      if (selected) setState(() => _filterStatus = 'onDuty');
                    },
                  ),
                ),
              ],
            ),
          ),
          // Guards list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayGuards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No guards found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add Guard'),
                                onPressed: () => _showAddGuardDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGuards,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _displayGuards.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final guard = _displayGuards[index];
                            return _buildGuardCard(guard);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGuardDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Guard'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGuardCard(Map<String, dynamic> guard) {
    final isOnDuty = guard['dutyStatus']?.toString() == 'onDuty';
    final isFree = !isOnDuty && (guard['status']?.toString() == 'active' || guard['status'] == null);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isOnDuty ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isOnDuty ? Colors.green.shade50 : Colors.blue.shade50,
                child: Icon(
                  Icons.shield,
                  color: isOnDuty ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guard['name']?.toString() ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (guard['experience']?.toString().isNotEmpty ?? false)
                      Text(
                        'Experience: ${guard['experience']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnDuty 
                      ? Colors.green.shade50 
                      : isFree 
                          ? Colors.blue.shade50 
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOnDuty ? 'On Duty' : isFree ? 'Free' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOnDuty 
                        ? Colors.green.shade700 
                        : isFree 
                            ? Colors.blue.shade700 
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (guard['phone']?.toString().isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    guard['phone']?.toString() ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          if (guard['email']?.toString().isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      guard['email']?.toString() ?? '',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                onPressed: () => _showEditGuardDialog(context, guard),
              ),
              if (isFree)
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  onPressed: () => _deleteGuard(guard['_id']?.toString() ?? ''),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddGuardDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final experienceCtl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Guard'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: experienceCtl,
                  decoration: const InputDecoration(
                    labelText: 'Experience (e.g., 5 years)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameCtl.text.trim().isEmpty || 
                    emailCtl.text.trim().isEmpty || 
                    phoneCtl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                setState(() => isLoading = true);
                try {
                  await _staffApi.createStaff(
                    name: nameCtl.text.trim(),
                    email: emailCtl.text.trim(),
                    phone: phoneCtl.text.trim(),
                    experience: experienceCtl.text.trim().isEmpty 
                        ? null 
                        : experienceCtl.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _loadGuards();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guard added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    final errorMsg = e.toString();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          errorMsg.contains('404') 
                              ? 'Route not found. Please restart the backend server.'
                              : errorMsg.contains('401') || errorMsg.contains('Organization context')
                                  ? 'Please ensure you are logged in as an organization.'
                                  : 'Error: $errorMsg',
                        ),
                        duration: const Duration(seconds: 4),
                        backgroundColor: Colors.red,
                      ),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGuardDialog(BuildContext context, Map<String, dynamic> guard) {
    final nameCtl = TextEditingController(text: guard['name']?.toString() ?? '');
    final emailCtl = TextEditingController(text: guard['email']?.toString() ?? '');
    final phoneCtl = TextEditingController(text: guard['phone']?.toString() ?? '');
    final experienceCtl = TextEditingController(text: guard['experience']?.toString() ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Guard'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: experienceCtl,
                  decoration: const InputDecoration(
                    labelText: 'Experience',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setState(() => isLoading = true);
                try {
                  await _staffApi.updateStaff(
                    staffId: guard['_id']?.toString() ?? '',
                    name: nameCtl.text.trim(),
                    email: emailCtl.text.trim(),
                    phone: phoneCtl.text.trim(),
                    experience: experienceCtl.text.trim().isEmpty 
                        ? null 
                        : experienceCtl.text.trim(),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _loadGuards();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guard updated successfully')),
                    );
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGuard(String guardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Guard'),
        content: const Text('Are you sure you want to delete this guard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _staffApi.deleteStaff(guardId);
      _loadGuards();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guard deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

