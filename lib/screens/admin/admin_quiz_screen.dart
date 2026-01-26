import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/quiz_question.dart';
// Note: We will dynamically load questions, but for seeding we might need to copy-paste the data 
// or import it if the file structure allows. 
// For now, I will include the seeding logic directly here with the data to ensure it works 
// without circular dependencies or import issues if I plan to delete quiz_data.dart later.

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  final _firestore = FirebaseFirestore.instance;

  // --- SEED DATA (Taken from quiz_data.dart) ---
  final List<Map<String, dynamic>> _seedQuestions = [
    {
      "question": "How do you feel most of the time these days?",
      "options": ["Happy", "Neutral", "Sad", "Anxious or stressed"],
      "scores": [4, 3, 2, 1],
    },
    {
      "question": "How often do you feel overwhelmed by your studies or responsibilities?",
      "options": ["Rarely", "Sometimes", "Often", "Almost always"],
      "scores": [4, 3, 2, 1],
    },
    {
      "question": "How often do you feel motivated to do your daily tasks?",
      "options": ["Almost everyday", "Sometimes", "Rarely", "Never"],
      "scores": [4, 3, 2, 1],
    },
    // ... I will add a few for testing, and we can add the rest or full list 
    // But to save context I'll just add the first few and a "Bulk Upload" function if needed.
    // actually let's just make it editable so they can add more.
  ];

  Future<void> _seedDatabase() async {
    // Check if empty first to avoid duplicates? Or user can just delete
    // For now, just add them.
    for (var i = 0; i < _seedQuestions.length; i++) {
      await _firestore.collection('questions').add({
        ..._seedQuestions[i],
        'order': i, // Keep order
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding Complete!')));
  }

  Future<void> _deleteQuestion(String id) async {
    await _firestore.collection('questions').doc(id).delete();
  }

  void _showAddEditDialog({DocumentSnapshot? doc}) {
    final isEditing = doc != null;
    final questionController = TextEditingController(text: isEditing ? doc['question'] : '');
    final orderController = TextEditingController(text: isEditing ? doc['order'].toString() : '0');

    // Parse existing options/scores or initialize empty
    List<Map<String, dynamic>> optionsList = [];
    if (isEditing) {
      final opts = List<String>.from(doc['options'] ?? []);
      final scrs = List<int>.from(doc['scores'] ?? []);
      for (int i = 0; i < opts.length; i++) {
        optionsList.add({
          "option": TextEditingController(text: opts[i]),
          "score": TextEditingController(text: i < scrs.length ? scrs[i].toString() : '0'),
        });
      }
    } else {
      // Add one default empty option row
      optionsList.add({
        "option": TextEditingController(),
        "score": TextEditingController(text: '0'),
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Question' : 'Add Question'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: questionController,
                        decoration: const InputDecoration(labelText: 'Question'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderController,
                        decoration: const InputDecoration(labelText: 'Order (Number)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(flex: 2, child: Text("Option", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 10),
                          Expanded(flex: 1, child: Text("Score", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 30), // Space for delete icon
                        ],
                      ),
                      const Divider(),
                      ...optionsList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['option'],
                                  decoration: const InputDecoration(
                                    hintText: 'Answer text',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: item['score'],
                                  decoration: const InputDecoration(
                                    hintText: 'Pts',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    optionsList.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      if (optionsList.length < 4)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              optionsList.add({
                                "option": TextEditingController(),
                                "score": TextEditingController(text: '0'),
                              });
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Option"),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (questionController.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question cannot be empty')));
                       return;
                    }

                    final options = optionsList.map((e) => (e['option'] as TextEditingController).text.trim()).where((t) => t.isNotEmpty).toList();
                    final scores = optionsList.map((e) => int.tryParse((e['score'] as TextEditingController).text.trim()) ?? 0).toList();
                    final order = int.tryParse(orderController.text) ?? 0;

                    if (options.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('At least one option is required')));
                       return;
                    }

                    // Trim scores to match valid options length if needed, 
                    // though UI logic above keeps them synced.
                    final validScores = scores.sublist(0, options.length);

                    final data = {
                      'question': questionController.text,
                      'options': options,
                      'scores': validScores,
                      'order': order,
                    };

                    try {
                      if (isEditing) {
                        await _firestore.collection('questions').doc(doc.id).update(data);
                      } else {
                        await _firestore.collection('questions').add(data);
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint("Error saving question: $e");
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
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
          // Seed Button (Temporary)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _seedDatabase, 
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Seed Sample Questions (Dev Only)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('questions').orderBy('order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text('No questions found. Add one!'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final question = data['question'] ?? 'No Question';
                    final options = List<String>.from(data['options'] ?? []);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(data['order'].toString())),
                        title: Text(question),
                        subtitle: Text("${options.length} options"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(doc: docs[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(docs[index].id),
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
