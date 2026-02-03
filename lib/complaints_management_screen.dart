import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'models/complaint_model.dart';
import 'models/user_model.dart';
import 'theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintsManagementScreen extends StatefulWidget {
  final bool isAdmin;
  const ComplaintsManagementScreen({super.key, this.isAdmin = false});

  @override
  State<ComplaintsManagementScreen> createState() =>
      _ComplaintsManagementScreenState();
}

class _ComplaintsManagementScreenState
    extends State<ComplaintsManagementScreen> {
  final DatabaseService _dbService = DatabaseService();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F8),
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? 'Manage Complaints' : 'My Assigned Complaints',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.midnightCharcoal,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildComplaintsList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Open', 'In Progress', 'Resolved'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 12, bottom: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              selectedColor: AppTheme.primaryGold,
              labelStyle: GoogleFonts.outfit(
                color: AppTheme.midnightCharcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintsList() {
    Stream<List<ComplaintModel>> complaintsStream;
    if (widget.isAdmin) {
      complaintsStream = _dbService.getAllComplaints();
    } else {
      complaintsStream = _dbService.getAssignedComplaints(_currentUid);
    }

    return StreamBuilder<List<ComplaintModel>>(
      stream: complaintsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final complaints = snapshot.data ?? [];
        final filtered = _selectedFilter == 'All'
            ? complaints
            : complaints.where((c) => c.status == _selectedFilter).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No complaints found',
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildComplaintCard(filtered[index]),
        );
      },
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    Color statusColor = _getStatusColor(complaint.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        key: PageStorageKey(complaint.id),
        textColor: AppTheme.midnightCharcoal,
        iconColor: AppTheme.midnightCharcoal,
        collapsedIconColor: AppTheme.midnightCharcoal,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.report_problem_outlined, color: statusColor),
        ),
        title: Text(
          complaint.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.midnightCharcoal,
          ),
        ),
        subtitle: Text(
          'Consumer UID: ${complaint.consumerUid.substring(0, 8)}...',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppTheme.midnightCharcoal.withValues(alpha: 0.6),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            complaint.status,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.midnightCharcoal,
                  ),
                ),
                Text(
                  complaint.description,
                  style: GoogleFonts.outfit(
                    color: AppTheme.midnightCharcoal.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                if (complaint.response != null) ...[
                  Text(
                    'Officer Response:',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  Text(
                    complaint.response!,
                    style: GoogleFonts.outfit(
                      color: AppTheme.midnightCharcoal.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildActionButtons(complaint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ComplaintModel complaint) {
    return Row(
      children: [
        if (complaint.status != 'Resolved')
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showUpdateStatusDialog(complaint),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.midnightCharcoal,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Update Status',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (widget.isAdmin && complaint.assignedOfficerUid == null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showAssignOfficerDialog(complaint),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.midnightCharcoal,
                side: const BorderSide(color: AppTheme.midnightCharcoal),
                backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Assign Officer',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showUpdateStatusDialog(ComplaintModel complaint) {
    final responseController = TextEditingController(text: complaint.response);
    String selectedStatus = complaint.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Update Status',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatusOption(
                        'In Progress',
                        Icons.sync_rounded,
                        Colors.orange,
                        selectedStatus == 'In Progress',
                        () =>
                            setModalState(() => selectedStatus = 'In Progress'),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusOption(
                        'Resolved',
                        Icons.check_circle_rounded,
                        Colors.green,
                        selectedStatus == 'Resolved',
                        () => setModalState(() => selectedStatus = 'Resolved'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Officer Response',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: responseController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter your response here...',
                      fillColor: const Color(0xFFF9F9F8),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.outfit(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _dbService.updateComplaintStatus(
                          complaint.id!,
                          selectedStatus,
                          response: responseController.text.trim(),
                        );
                        if (!mounted) return;
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.midnightCharcoal,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update Complaint',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.black.withValues(alpha: 0.05),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.black26),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignOfficerDialog(ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Text(
                    'Assign Officer',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.midnightCharcoal,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F9F8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _dbService.getAllUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data ?? [];
                  final officers =
                      users.where((u) => u.role == 'officer').toList();

                  if (officers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_rounded,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No officers found',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: officers.length,
                    itemBuilder: (context, index) {
                      final officer = officers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryGold.withValues(alpha: 0.1),
                            child: Text(
                              officer.name.isNotEmpty
                                  ? officer.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.outfit(
                                color: AppTheme.midnightCharcoal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            officer.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.midnightCharcoal,
                            ),
                          ),
                          subtitle: Text(
                            officer.email,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            await _dbService.updateComplaintAssignment(
                              complaint.id!,
                              officer.uid,
                            );
                            if (!mounted) return;
                            navigator.pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Complaint assigned to ${officer.name}'),
                                backgroundColor: AppTheme.successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
