import 'package:flutter/material.dart';
import 'api/service_api.dart';
import 'models/org.dart';

class SearchCompaniesPage extends StatefulWidget {
  const SearchCompaniesPage({super.key});

  @override
  State<SearchCompaniesPage> createState() => _SearchCompaniesPageState();
}

class _SearchCompaniesPageState extends State<SearchCompaniesPage> {
  final _api = ServiceApi();
  final _searchController = TextEditingController();
  List<Org> _allOrgs = [];
  List<Org> _filteredOrgs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterOrganizations();
    });
  }

  void _filterOrganizations() {
    if (_searchQuery.isEmpty) {
      _filteredOrgs = List.from(_allOrgs);
    } else {
      _filteredOrgs = _allOrgs.where((org) {
        return org.name.toLowerCase().contains(_searchQuery) ||
            org.address.toLowerCase().contains(_searchQuery) ||
            org.phone.toLowerCase().contains(_searchQuery) ||
            org.email.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadOrganizations() async {
    setState(() => _isLoading = true);
    try {
      final orgs = await _api.fetchOrgs();
      setState(() {
        _allOrgs = orgs;
        _filteredOrgs = orgs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading organizations: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search service and organization',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Organizations list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredOrgs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No organizations found'
                                : 'No results found',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrganizations,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredOrgs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final org = _filteredOrgs[index];
                          return _buildCompanyCard(org);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(Org org) {
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
      ),
      child: Row(
        children: [
          // Company icon on the left
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.apartment, color: Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(width: 12),
          // Company details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company name (bold, larger)
                Text(
                  org.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Location with map pin icon
                if (org.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            org.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Phone with phone icon
                if (org.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          org.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Email with envelope icon
                if (org.email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            org.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

