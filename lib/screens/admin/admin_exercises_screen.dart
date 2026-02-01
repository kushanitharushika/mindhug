import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.05),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minScoreController,
                      decoration: InputDecoration(
                        labelText: 'Min Score',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxScoreController,
                      decoration: InputDecoration(
                        labelText: 'Max Score',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
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
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
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
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by Dashboard
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _seedDatabase, 
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text("Seed Exercises"),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
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

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                  itemCount: docs.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${data['minScore']}",
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          data['title'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['desc'] ?? '', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              Text(
                                "Range: ${data['minScore']} - ${data['maxScore']}",
                                style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey.shade400, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => _showAddEditDialog(doc: docs[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
