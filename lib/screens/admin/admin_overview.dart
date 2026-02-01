import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/admin_stat_card.dart';

class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 600 ? 4 : 2;
              
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                   _buildStatStream(
                    collection: 'users',
                    title: 'Total Users',
                    icon: Icons.people_outline,
                    color: Colors.blueAccent,
                  ),
                   _buildStatStream(
                    collection: 'questions',
                    title: 'Quiz Questions',
                    icon: Icons.quiz_outlined,
                    color: Colors.orangeAccent,
                  ),
                   _buildStatStream(
                    collection: 'exercises',
                    title: 'Exercises',
                    icon: Icons.fitness_center_outlined,
                    color: Colors.purpleAccent,
                  ),
                   // Placeholder for future stats
                   const AdminStatCard(
                    title: "Pending", 
                    value: "0", 
                    icon: Icons.pending_actions, 
                    color: Colors.teal,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Add some quick action buttons or recent activity here if needed
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.rocket_launch, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("More insights coming soon!"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatStream({
    required String collection,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String value = "...";
        if (snapshot.hasData) {
          value = snapshot.data!.docs.length.toString();
        }
        return AdminStatCard(
          title: title,
          value: value,
          icon: icon,
          color: color,
        );
      },
    );
  }
}
