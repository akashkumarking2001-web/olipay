import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.tealAccent),
            onPressed: () {
              // Refresh is automatic with StreamBuilder
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').orderBy('joinedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          final users = snapshot.data?.docs ?? [];
          
          // Calculate Statistics
          int total = users.length;
          int active = 0;
          int expired = 0;
          
          final now = DateTime.now();

          for (var doc in users) {
             final data = doc.data() as Map<String, dynamic>;
             final expiry = (data['expiryDate'] as Timestamp?)?.toDate();
             if (expiry != null && expiry.isAfter(now)) {
               active++;
             } else {
               expired++;
             }
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subscribers Overview', style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Total Users', total.toString(), Colors.blueAccent),
                    _buildStatCard('Active', active.toString(), Colors.greenAccent),
                    _buildStatCard('Expired', expired.toString(), Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('User Records', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: users.isEmpty 
                    ? const Center(child: Text("No users found.", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;
                      final shopName = data['shopName'] ?? 'No Name';
                      final phone = data['phone'] ?? 'N/A';
                      final plan = data['plan'] ?? 'Trial';
                      final expiry = (data['expiryDate'] as Timestamp?)?.toDate();
                      
                      final bool isExpired = expiry == null || expiry.isBefore(now);
                      final bool isExpiringSoon = expiry != null && expiry.isAfter(now) && expiry.difference(now).inDays < 3;

                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpired ? Colors.red.withOpacity(0.2) : (isExpiringSoon ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
                            child: Icon(
                              isExpired ? Icons.cancel : (isExpiringSoon ? Icons.warning : Icons.check_circle),
                              color: isExpired ? Colors.redAccent : (isExpiringSoon ? Colors.orange : Colors.greenAccent),
                            ),
                          ),
                          title: Text(shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('$phone • $plan', style: const TextStyle(color: Colors.white54)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isExpired ? 'Expired' : (isExpiringSoon ? 'Expiring Soon' : 'Active'),
                                style: TextStyle(
                                  color: isExpired ? Colors.redAccent : (isExpiringSoon ? Colors.orangeAccent : Colors.greenAccent),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                expiry != null ? DateFormat('dd MMM yyyy').format(expiry) : 'N/A',
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}

