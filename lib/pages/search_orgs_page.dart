import 'package:flutter/material.dart';
import '../api/service_api.dart';
import '../models/org.dart';
import 'book_service_page.dart';

class SearchOrgsPage extends StatelessWidget {
  SearchOrgsPage({super.key});
  final _api = ServiceApi();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Org>>(
      future: _api.fetchOrgs(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No organizations found'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final o = items[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))]),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE8F1FD), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.apartment, color: Color(0xFF1E88E5))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(children: [const Icon(Icons.location_on, size: 14), const SizedBox(width: 4), Expanded(child: Text(o.address, overflow: TextOverflow.ellipsis))]),
                  Row(children: [const Icon(Icons.call, size: 14), const SizedBox(width: 4), Text(o.phone)]),
                ])),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11B47A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookServicePage(orgId: o.id, orgName: o.name)));
                  },
                  child: const Text('Connect'),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
