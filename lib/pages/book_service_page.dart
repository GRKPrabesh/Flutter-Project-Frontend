import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/service_api.dart';
import '../models/service.dart';

class BookServicePage extends StatefulWidget {
  final String orgId;
  final String orgName;
  const BookServicePage({super.key, required this.orgId, required this.orgName});

  @override
  State<BookServicePage> createState() => _BookServicePageState();
}

class _BookServicePageState extends State<BookServicePage> {
  final _api = ServiceApi();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  DateTime _selected = DateTime.now();
  ServiceItem? _service;
  bool _loading = false;

  @override
  void dispose() {
    _address.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selected,
    );
    if (d != null) setState(() => _selected = d);
  }

  Future<void> _confirm() async {
    if (_service == null || _address.text.isEmpty || _contact.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select service, date and enter address/contact')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.createBooking(serviceId: _service!.id, date: _selected, address: _address.text, contact: _contact.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context)), title: const Text('Book Service')),
      body: FutureBuilder<List<ServiceItem>>(
        future: _api.fetchServicesByOrg(widget.orgId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final services = snap.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(widget.orgName, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DropdownButtonFormField<ServiceItem>(
                value: _service,
                items: services
                    .map((s) => DropdownMenuItem(value: s, child: Text('${s.title} (NPR ${s.price})')))
                    .toList(),
                onChanged: (v) => setState(() => _service = v),
                decoration: const InputDecoration(labelText: 'Service', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('When do you want the service?'),
                subtitle: Text(DateFormat('EEE, MMM d, y').format(_selected)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contact', border: OutlineInputBorder())),
              const Spacer(),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _confirm,
                  child: Text(_loading ? 'Submitting...' : 'Confirm Booking'),
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}
