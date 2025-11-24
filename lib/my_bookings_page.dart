import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/service_api.dart';
import 'models/booking.dart';

class MyBookingsPage extends StatelessWidget {
  MyBookingsPage({super.key});
  final _api = ServiceApi();

  Color _badgeColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return const Color(0xFFFFD54F);
      case BookingStatus.confirmed:
        return const Color(0xFF8BC34A);
      case BookingStatus.cancelled:
        return const Color(0xFFE57373);
      case BookingStatus.completed:
        return const Color(0xFF4CAF50);
    }
  }

  String _label(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Booking>>(
      future: _api.fetchBookings(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Text('Failed to load bookings'));
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No bookings yet'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final b = items[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
                border: Border.all(
                  color: _badgeColor(b.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.serviceTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('by ${b.orgName}', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: _badgeColor(b.status), borderRadius: BorderRadius.circular(16)),
                      child: Text(_label(b.status), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('MMM d, y').format(b.date)}${b.time != null ? ' at ${b.time}' : ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (b.durationDays > 1) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${b.durationDays} days)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 16, color: Color(0xFF11B47A)),
                    const SizedBox(width: 6),
                    Text('NPR ${b.price}', style: const TextStyle(color: Color(0xFF11B47A), fontWeight: FontWeight.w700)),
                  ],
                ),
                if (b.assignedGuard != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              b.assignedGuard!['name']?.toString() ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (b.assignedGuard!['phone']?.toString().isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                b.assignedGuard!['phone']?.toString() ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                        if (b.assignedGuard!['experience']?.toString().isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                'Experience: ${b.assignedGuard!['experience']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ]),
            );
          },
        );
      },
    );
  }
}
