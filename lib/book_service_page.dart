import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/service_api.dart';
import 'models/service.dart';

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
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationDays = 1;
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

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _confirm() async {
    if (_service == null || _address.text.isEmpty || _contact.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select service, date, time and enter address/contact')));
      return;
    }
    setState(() => _loading = true);
    try {
      final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      await _api.createBooking(
        serviceId: _service!.id,
        date: _selected,
        time: timeString,
        durationDays: _durationDays,
        address: _address.text,
        contact: _contact.text,
      );
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
          
          // Reset selected service if it's not in the new list
          if (_service != null && !services.any((s) => s.id == _service!.id)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _service = null);
            });
          }
          
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No services available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This organization has not added any services yet.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.apartment, color: const Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.orgName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select a Service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ServiceItem>(
                value: _service,
                items: services
                    .map((s) => DropdownMenuItem<ServiceItem>(
                      value: s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'NPR ${s.price}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ))
                    .toList(),
                onChanged: (ServiceItem? v) => setState(() => _service = v),
                decoration: InputDecoration(
                  labelText: 'Choose a service',
                  hintText: 'Select from available services',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Service Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('EEE, MMM d, y').format(_selected),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Time',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickTime,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _durationDays,
                decoration: InputDecoration(
                  labelText: 'Duration (Days)',
                  hintText: 'Select duration',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.schedule),
                ),
                items: List.generate(30, (index) => index + 1)
                    .map((days) => DropdownMenuItem(
                      value: days,
                      child: Text('$days ${days == 1 ? 'day' : 'days'}'),
                    ))
                    .toList(),
                onChanged: (int? value) {
                  if (value != null) setState(() => _durationDays = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _address,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Service Address',
                  hintText: 'Enter the address where service is needed',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'Enter your contact number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _confirm,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}
