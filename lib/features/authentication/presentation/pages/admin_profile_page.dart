import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _approveRequest(String uid, String email) async {
    final userRequestRef = _firestore.collection('usersRequest').doc(uid);
    final userRef = _firestore.collection('users').doc(uid);

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Admin Request'),
        content:
            Text('Do you want approve $email? This user will become an admin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await userRequestRef.update({'status': true});
      await userRef.update({'is_approved': true});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approve Success : $email is now an admin')),
        );
      }
      setState(() {}); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6FFB7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            // Illustration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/asset2.png', // Replace with your illustration asset
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You Are Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF4B7F52),
                    ),
                  ),
                ],
              ),
            ),
            // Admin Requests List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('usersRequest')
                    .where('status', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No admin requests found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final requests = snapshot.data!.docs;
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final data =
                          requests[index].data() as Map<String, dynamic>;
                      final email = data['email'] ?? '';
                      final requestedAt = data['requestedAt'];
                      final uid = data['uid'] ?? '';
                      String dateStr = '';
                      if (requestedAt != null) {
                        try {
                          dateStr = DateFormat('dd MMM yyyy, HH:mm').format(
                            (requestedAt as Timestamp).toDate(),
                          );
                        } catch (_) {}
                      }
                      return Card(
                        color: const Color(0xFFFFD93D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: const Text(
                            'ADMIN REQUEST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B7F52),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              if (dateStr.isNotEmpty)
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.verified,
                                color: Color(0xFF4B7F52), size: 32),
                            tooltip: 'Approve',
                            onPressed: () => _approveRequest(uid, email),
                          ),
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
}
