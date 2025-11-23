import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({Key? key, required this.complaint})
      : super(key: key);

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  late String _selectedStatus;
  final _notesController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.complaintStatus;
    _notesController.text = widget.complaint.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _updateComplaint() async {
    if (_selectedStatus == widget.complaint.complaintStatus &&
        _notesController.text == (widget.complaint.notes ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No changes made'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final result = await ApiService.updateComplaint(
      complaintId: widget.complaint.complaintId,
      status: _selectedStatus,
      notes: _notesController.text,
    );

    setState(() => _isUpdating = false);

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Complaint updated successfully'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Update failed'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.complaint.jobId),
          backgroundColor: const Color(0xFF2c3e50)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.complaint.jobId,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        StatusBadge(status: widget.complaint.complaintStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PriorityBadge(priority: widget.complaint.priority),
                        const SizedBox(width: 8),
                        Text(_formatDate(widget.complaint.complaintDate),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildInfoRow('Name', widget.complaint.customerName),
                    if (widget.complaint.customerPhone != null)
                      _buildInfoRow('Phone', widget.complaint.customerPhone!),
                    if (widget.complaint.customerAddress != null)
                      _buildInfoRow(
                          'Address', widget.complaint.customerAddress!),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Complaint Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    if (widget.complaint.typeOfService != null)
                      _buildInfoRow(
                          'Service Type', widget.complaint.typeOfService!),
                    if (widget.complaint.typeOfDevice != null)
                      _buildInfoRow(
                          'Device Type', widget.complaint.typeOfDevice!),
                    if (widget.complaint.brand != null)
                      _buildInfoRow('Brand', widget.complaint.brand!),
                    const SizedBox(height: 8),
                    const Text('Description:',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(widget.complaint.complaintDescription,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Update Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                          labelText: 'Status', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: 'progressing', child: Text('Progressing')),
                        DropdownMenuItem(
                            value: 'resolved', child: Text('Resolved')),
                        DropdownMenuItem(
                            value: 'follow-up', child: Text('Follow-up')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Add your notes here...',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateComplaint,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2c3e50)),
                        child: _isUpdating
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)))
                            : const Text('Update Complaint',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
