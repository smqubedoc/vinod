import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/firebase_messaging_service.dart';
import '../widgets/complaint_card.dart';
import 'login_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  bool _isLoading = true;
  User? _currentUser;
  String _filterStatus = 'all';
  bool _showFcmToken = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadComplaints();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getComplaints();

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _complaints = result['complaints'] as List<Complaint>;
        _applyFilter();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load complaints'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilter() {
    if (_filterStatus == 'all') {
      _filteredComplaints = _complaints;
    } else {
      _filteredComplaints =
          _complaints.where((c) => c.complaintStatus == _filterStatus).toList();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: const Color(0xFF2c3e50),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(_currentUser?.userName ?? 'User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // FCM Token Display Section
          Container(
            width: double.infinity,
            color: Colors.blue[50],
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showFcmToken = !_showFcmToken;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _showFcmToken ? Icons.expand_less : Icons.expand_more,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FCM Token',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const Spacer(),
                        if (FirebaseMessagingService.fcmToken != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Generated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Not Generated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_showFcmToken)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                FirebaseMessagingService.fcmToken ?? 'Token not generated yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: FirebaseMessagingService.fcmToken != null
                                      ? Colors.black87
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (FirebaseMessagingService.fcmToken != null)
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: FirebaseMessagingService.fcmToken!,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('FCM Token copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                tooltip: 'Copy to clipboard',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        _buildFilterChip('Pending', 'pending'),
                        _buildFilterChip('Progressing', 'progressing'),
                        _buildFilterChip('Resolved', 'resolved'),
                        _buildFilterChip('Follow-up', 'follow-up'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No complaints found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadComplaints,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComplaints,
                        child: ListView.builder(
                          itemCount: _filteredComplaints.length,
                          itemBuilder: (context, index) {
                            return ComplaintCard(
                              complaint: _filteredComplaints[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
            _applyFilter();
          });
        },
        selectedColor: const Color(0xFF667eea),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
