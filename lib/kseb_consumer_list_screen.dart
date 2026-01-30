import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'kseb_consumer_details_screen.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KsebConsumerListScreen extends StatefulWidget {
  const KsebConsumerListScreen({super.key});

  @override
  State<KsebConsumerListScreen> createState() => _KsebConsumerListScreenState();
}

class _KsebConsumerListScreenState extends State<KsebConsumerListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String _officerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedFilter = 'All Consumers';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<UserModel> _filterConsumers(List<UserModel> consumers) {
    return consumers.where((consumer) {
      final matchesSearch =
          consumer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              consumer.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All Consumers' ||
          (consumer.isActive && _selectedFilter == 'Active') ||
          (!consumer.isActive && _selectedFilter == 'Disc.');

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
            StreamBuilder<List<UserModel>>(
              stream: _dbService.getAssignedConsumers(_officerUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final filtered = _filterConsumers(snapshot.data ?? []);
                return _buildConsumerList(filtered);
              },
            ),
            const SizedBox(height: 80), // Space for FAB
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

  // ... (keeping _buildHeader as is) ...

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
                color: const Color(0xFF003840), // Dark teal/blue from image
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
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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

  Widget _buildConsumerList(List<UserModel> filtered) {
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

  Widget _buildConsumerCard(UserModel consumer) {
    Color statusColor =
        consumer.isActive ? const Color(0xFF2EBD59) : const Color(0xFFD32F2F);

    return GestureDetector(
      onTap: () {
        // Since KsebConsumerDetailsScreen expects a Map<String, dynamic>
        // and we have a UserModel, we'll convert it or update the screen.
        // For now, let's pass a map.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KsebConsumerDetailsScreen(
              consumer: {
                'name': consumer.name,
                'email': consumer.email,
                'status': consumer.isActive ? 'ACTIVE' : 'DISC.',
                'consumerId': consumer.uid.substring(0, 6),
                'meterId': 'SM-${consumer.uid.substring(0, 6)}',
                'type': 'individual',
                'uid': consumer.uid,
              },
            ),
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
                                consumer.name,
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
                                    consumer.isActive ? 'ACTIVE' : 'DISC.',
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
                          consumer.email,
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
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel consumer) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFFFECB3), // Light amber
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          consumer.name[0],
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
        return const Color(0xFF2EBD59); // Green
      case 'PENDING':
        return const Color(0xFFFF8A00); // Orange/Yellow
      case 'DISC.':
      case 'DISCONNECTED':
        return const Color(0xFFD32F2F); // Red
      default:
        return Colors.grey;
    }
  }
}
