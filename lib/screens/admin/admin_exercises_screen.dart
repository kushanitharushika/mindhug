import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminExercisesScreen extends StatefulWidget {
  const AdminExercisesScreen({super.key});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  final _firestore = FirebaseFirestore.instance;

  // --- SEED DATA (Taken from exercises_screen.dart logic) ---
  final List<Map<String, dynamic>> _seedExercises = [
    // Score >= 40
    {"title": "Gratitude Reflection", "desc": "List 3 things you’re grateful for today.", "minScore": 40, "maxScore": 100},
    {"title": "Mindful Breathing", "desc": "Slowly breathe in and out for 3 minutes.", "minScore": 40, "maxScore": 100},
    {"title": "Daily Stretching", "desc": "5 minutes of full body stretches to energize.", "minScore": 40, "maxScore": 100},
    
    // Score >= 32 (Range 32-39)
    {"title": "4-7-8 Breathing", "desc": "Inhale 4s, hold 7s, exhale 8s.", "minScore": 32, "maxScore": 39},
    {"title": "Journaling", "desc": "Write down your thoughts freely.", "minScore": 32, "maxScore": 39},
    
    // Score >= 24 (Range 24-31)
    {"title": "5-4-3-2-1 Grounding", "desc": "Name 5 things you see, 4 feel, 3 hear.", "minScore": 24, "maxScore": 31},
    {"title": "Body Relaxation", "desc": "Relax each muscle group slowly.", "minScore": 24, "maxScore": 31},
    
    // Else (Range 0-23)
    {"title": "Calm Breathing", "desc": "Breathe gently and slowly for 3 minutes.", "minScore": 0, "maxScore": 23},
    {"title": "Reach Out", "desc": "Consider talking to someone you trust.", "minScore": 0, "maxScore": 23},
  ];

  Future<void> _seedDatabase() async {
    for (var exercise in _seedExercises) {
      await _firestore.collection('exercises').add(exercise);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercises Seeded!')));
  }

  Future<void> _deleteExercise(String id) async {
    await _firestore.collection('exercises').doc(id).delete();
  }

  void _showAddEditDialog({DocumentSnapshot? doc}) {
    final isEditing = doc != null;
    final titleController = TextEditingController(text: isEditing ? doc['title'] : '');
    final descController = TextEditingController(text: isEditing ? doc['desc'] : '');
    final minScoreController = TextEditingController(text: isEditing ? doc['minScore'].toString() : '0');
    final maxScoreController = TextEditingController(text: isEditing ? doc['maxScore'].toString() : '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Min Score',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("-"),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxScoreController,
                      decoration: const InputDecoration(
                        labelText: 'Max Score',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
                 return;
              }

              final min = int.tryParse(minScoreController.text) ?? 0;
              final max = int.tryParse(maxScoreController.text) ?? 100;

              if (min > max) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Min Score cannot be greater than Max Score')));
                return;
              }

              final data = {
                'title': title,
                'desc': descController.text.trim(),
                'minScore': min,
                'maxScore': max,
              };

              try {
                if (isEditing) {
                  await _firestore.collection('exercises').doc(doc.id).update(data);
                } else {
                  await _firestore.collection('exercises').add(data);
                }
                if (mounted) Navigator.pop(context);
              } catch (e) {
                 if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _seedDatabase, 
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Seed Exercises (Dev Only)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('exercises').orderBy('minScore').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text('No exercises found. Add one!'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text("${data['minScore']}"),
                        ),
                        title: Text(data['title'] ?? 'No Title'),
                        subtitle: Text(data['desc'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${data['minScore']}-${data['maxScore']}", style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(doc: docs[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExercise(docs[index].id),
                            ),
                          ],
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
    );
  }
}
