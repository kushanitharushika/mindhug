import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              
              // Handle potential missing fields gracefully
              final name = user['Name'] ?? 'Unknown Name';
              final email = user['Email'] ?? 'No Email';
              final role = user['Role'] ?? 'user';
              final phone = user['PhoneNumber'] ?? 'N/A';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == 'admin' ? Colors.purple : Colors.blue,
                    child: Icon(
                      role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      if (phone != 'N/A') Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(role.toUpperCase(), style: const TextStyle(fontSize: 10)),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
