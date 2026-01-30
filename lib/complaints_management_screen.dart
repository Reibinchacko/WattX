import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'models/complaint_model.dart';
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
                color: isSelected ? Colors.white : AppTheme.midnightCharcoal,
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
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Consumer UID: ${complaint.consumerUid.substring(0, 8)}...',
          style: GoogleFonts.outfit(fontSize: 12),
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
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                Text(
                  complaint.description,
                  style: GoogleFonts.outfit(),
                ),
                const SizedBox(height: 16),
                if (complaint.response != null) ...[
                  Text(
                    'Officer Response:',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    complaint.response!,
                    style: GoogleFonts.outfit(),
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
    final responseController = TextEditingController();
    String selectedStatus =
        complaint.status == 'Open' ? 'In Progress' : 'Resolved';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Complaint', style: GoogleFonts.outfit()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: ['In Progress', 'Resolved']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => selectedStatus = val ?? selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Response/Comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignOfficerDialog(ComplaintModel complaint) {
    // In a real app, this would fetch a list of officers
    // For this demonstration, we'll use a hardcoded UID or a simple input
    final uidController = TextEditingController(text: 'OFFICER_UID_1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign to Officer', style: GoogleFonts.outfit()),
        content: TextField(
          controller: uidController,
          decoration: const InputDecoration(labelText: 'Officer UID'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _dbService.updateComplaintAssignment(
                complaint.id!,
                uidController.text.trim(),
              );
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text('Assign'),
          ),
        ],
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
