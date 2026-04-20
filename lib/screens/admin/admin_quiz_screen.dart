import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../quiz/quiz_data.dart';

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _seedDatabase() async {
    for (var i = 0; i < quizQuestions.length; i++) {
      final questionText = quizQuestions[i].question;
      final slug = questionText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
      
      await _firestore.collection('questions').doc(slug).set({
        'question': quizQuestions[i].question,
        'options': quizQuestions[i].options,
        'scores': quizQuestions[i].scores,
        'order': i, // Keep order
      }, SetOptions(merge: true));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Quiz Questions Seeded!')));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(isEditing ? 'Edit Question' : 'Add Question', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: questionController,
                        decoration: InputDecoration(
                          labelText: 'Question',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: orderController,
                        decoration: InputDecoration(
                          labelText: 'Order (Number)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(flex: 2, child: Text("Option", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 10),
                          Expanded(flex: 1, child: Text("Score", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 32),
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
                                    hintText: 'Answer',
                                    isDense: true,
                                    border: UnderlineInputBorder(),
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
                                    border: UnderlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (optionsList.length < 5) {
                            setState(() {
                              optionsList.add({
                                "option": TextEditingController(),
                                "score": TextEditingController(text: '0'),
                              });
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 5 options allowed')));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Option"),
                        style: OutlinedButton.styleFrom(
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
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
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      debugPrint("Error saving question: $e");
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
            );
          },
        );
      },
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
          // Header Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _seedDatabase, 
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text("Seed Questions"),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('questions').orderBy('order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No questions found.', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                  itemCount: docs.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final question = data['question'] ?? 'No Question';
                    final options = List<String>.from(data['options'] ?? []);

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
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary.withOpacity(0.1),
                            child: Text(
                              "${data['order']}", 
                              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            question,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2D3142),
                            ),
                          ),
                          subtitle: Text(
                            "${options.length} options",
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey),
                          ),
                          childrenPadding: const EdgeInsets.all(16),
                          children: [
                            const Divider(),
                            ...options.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 8, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(e.value)),
                                ],
                              ),
                            )),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showAddEditDialog(doc: docs[index]),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text("Edit"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => _deleteQuestion(docs[index].id),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text("Delete"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
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
