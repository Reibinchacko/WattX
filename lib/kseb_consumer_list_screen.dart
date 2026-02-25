import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'kseb_consumer_details_screen.dart';

class KsebConsumerListScreen extends StatefulWidget {
  const KsebConsumerListScreen({super.key});

  @override
  State<KsebConsumerListScreen> createState() => _KsebConsumerListScreenState();
}

class _KsebConsumerListScreenState extends State<KsebConsumerListScreen> {
  String _selectedFilter = 'All Consumers';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _consumers = [
    {
      'name': 'Priya Nair',
      'consumerId': '#882910',
      'meterId': 'SM-882910',
      'location': 'Kowdiar, TVM',
      'status': 'ACTIVE',
      'type': 'individual',
      'image': 'assets/images/user1.png',
    },
    {
      'name': 'Green Valley Apts',
      'consumerId': '#882911',
      'meterId': 'SM-882911',
      'location': 'Pattom, TVM',
      'status': 'PENDING',
      'type': 'apartment',
    },
    {
      'name': 'Arun Kumar',
      'consumerId': '#883042',
      'meterId': 'SM-883042',
      'location': 'Vellayambalam',
      'status': 'ACTIVE',
      'type': 'individual',
    },
    {
      'name': 'Lakshmi Towers',
      'consumerId': '#881002',
      'meterId': 'SM-881002',
      'location': 'Kazhakkoottam',
      'status': 'DISC.',
      'type': 'business',
    },
  ];

  List<Map<String, dynamic>> get _filteredConsumers {
    return _consumers.where((consumer) {
      final matchesSearch =
          consumer['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              consumer['consumerId']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              consumer['meterId']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All Consumers' ||
          consumer['status'].toUpperCase() == _selectedFilter.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddConsumerDialog(),
        backgroundColor: AppTheme.primaryGold,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildFilterChips(),
            const SizedBox(height: 24),
            _buildConsumerList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showAddConsumerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Consumer',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: InputDecoration(
                    hintText: 'Consumer Name', hintStyle: GoogleFonts.inter())),
            const SizedBox(height: 12),
            TextField(
                decoration: InputDecoration(
                    hintText: 'Meter ID', hintStyle: GoogleFonts.inter())),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumer Mgmt',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF003840),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Zone 4 - Trivandrum North',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.notifications,
                    size: 28, color: Colors.black87),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'KO',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search Name, Consumer #, or Meter ID...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.clear, color: Colors.grey),
                )
              : const Icon(Icons.tune, color: AppTheme.primaryGold),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Consumers', 'Active', 'Pending', 'Disc.'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGold
                      : const Color(0xFFFFF9C4).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppTheme.primaryGold.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    if (filter != 'All Consumers') ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(filter.toUpperCase()),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      filter,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.midnightCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConsumerList() {
    final filtered = _filteredConsumers;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.person_search_rounded,
                  size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No consumers found',
                  style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final consumer = filtered[index];
        return _buildConsumerCard(consumer);
      },
    );
  }

  Widget _buildConsumerCard(Map<String, dynamic> consumer) {
    Color statusColor = _getStatusColor(consumer['status']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KsebConsumerDetailsScreen(consumer: consumer),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(consumer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                consumer['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.midnightCharcoal,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    consumer['status'],
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Consumer ${consumer["consumerId"]}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF637381),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'METER ID',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF919EAB),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.bolt,
                                size: 16, color: AppTheme.primaryGold),
                            const SizedBox(width: 4),
                            Text(
                              consumer['meterId'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.midnightCharcoal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> consumer) {
    if (consumer['type'] == 'apartment') {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F2F1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.apartment_rounded,
            color: Color(0xFF00695C), size: 24),
      );
    } else if (consumer['type'] == 'business') {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.business_rounded, color: Colors.grey, size: 24),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFFFECB3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          consumer['name'][0],
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6D4C41),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF2EBD59);
      case 'PENDING':
        return const Color(0xFFFF8A00);
      case 'DISC.':
      case 'DISCONNECTED':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }
}
