import 'package:flutter/material.dart';
import '../api/service_api.dart';
import '../models/booking.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: FutureBuilder<List<Booking>>(
        future: _api.fetchBookings(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.serviceTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('by ${b.orgName}', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('NPR ${b.price}', style: const TextStyle(color: Color(0xFF11B47A), fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _badgeColor(b.status), borderRadius: BorderRadius.circular(16)),
                      child: Text(_label(b.status), style: const TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ])
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
