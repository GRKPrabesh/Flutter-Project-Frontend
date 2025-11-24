import 'package:flutter/material.dart';
import 'api/org_booking_api.dart';
import 'api/staff_api.dart';

class OrgOrdersPage extends StatefulWidget {
  const OrgOrdersPage({super.key});

  @override
  State<OrgOrdersPage> createState() => _OrgOrdersPageState();
}

class _OrgOrdersPageState extends State<OrgOrdersPage> {
  final _bookingApi = OrgBookingApi();
  final _staffApi = StaffApi();
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _freeGuards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final [orders, guards] = await Future.wait([
        _bookingApi.fetchBookings(),
        _staffApi.fetchStaff(),
      ]);
      setState(() {
        _orders = orders;
        _freeGuards = guards.where((g) => 
          (g['status']?.toString() == 'active' || g['status'] == null) &&
          (g['dutyStatus']?.toString() != 'onDuty' || g['dutyStatus'] == null)
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _assignGuard(String bookingId, String guardId) async {
    try {
      await _bookingApi.assignGuard(bookingId: bookingId, staffId: guardId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guard assigned successfully')),
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

  Future<void> _acceptOrder(String bookingId) async {
    try {
      final result = await _bookingApi.acceptBooking(bookingId);
      _loadData();
      if (mounted) {
        final message = result['message']?.toString() ?? 'Order accepted';
        final hasGuard = result['booking']?['assignedStaffId'] != null;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: hasGuard ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? 'pending';
    final serviceName = order['serviceId']?['name']?.toString() ?? 'Unknown Service';
    final clientName = order['userId']?['name']?.toString() ?? 'Unknown Client';
    final clientEmail = order['userId']?['email']?.toString() ?? '';
    final date = order['requiredDate']?.toString() ?? '';
    final address = order['address']?.toString() ?? '';
    final assignedGuard = order['assignedStaffId'];
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';

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
          color: isPending 
              ? Colors.orange 
              : isConfirmed 
                  ? Colors.green 
                  : Colors.grey,
          width: 2,
        ),
      ),
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
                      'Client: $clientName',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    if (clientEmail.isNotEmpty)
                      Text(
                        clientEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending 
                      ? Colors.orange.shade50 
                      : isConfirmed 
                          ? Colors.green.shade50 
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPending 
                        ? Colors.orange.shade700 
                        : isConfirmed 
                            ? Colors.green.shade700 
                            : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (date.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Date: ${date.split('T')[0]}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          if (assignedGuard != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Assigned Guard',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        assignedGuard['name']?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (assignedGuard['phone']?.toString().isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          assignedGuard['phone']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept & Assign Guard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _acceptOrder(order['_id']?.toString() ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                if (_freeGuards.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Assign Guard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showAssignGuardDialog(order),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _showAssignGuardDialog(Map<String, dynamic> order) {
    if (_freeGuards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No free guards available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Guard'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _freeGuards.length,
            itemBuilder: (context, index) {
              final guard = _freeGuards[index];
              return ListTile(
                leading: const Icon(Icons.shield),
                title: Text(guard['name']?.toString() ?? 'Unknown'),
                subtitle: Text(
                  '${guard['phone'] ?? ''}${guard['experience'] != null ? ' • ${guard['experience']}' : ''}',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _assignGuard(
                    order['_id']?.toString() ?? '',
                    guard['_id']?.toString() ?? '',
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

