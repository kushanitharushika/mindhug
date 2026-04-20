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

  // --- SEED DATA ---
  final List<Map<String, dynamic>> _seedExercises = [
    {
      "title": "Thought Reframing",
      "desc": "Reduces overthinking by balancing negative thoughts.",
      "minScore": 0,
      "maxScore": 50,
      "duration": "5 mins",
      "type": "journaling",
      "benefits": "Reduces overthinking and serves as the core of Cognitive Behavioral Therapy.",
      "steps": [
        "Write a negative thought",
        "Ask: 'Is this 100% true?'",
        "Replace with a balanced thought"
      ]
    },
    {
      "title": "2-Minute Brain Dump",
      "desc": "Clears mental overload by writing everything down.",
      "minScore": 0,
      "maxScore": 60,
      "duration": "2 mins",
      "type": "journaling",
      "benefits": "Clears mental overload and frees up working memory.",
      "steps": [
        "Set timer for 2 minutes",
        "Write everything in your mind",
        "Do not stop or filter",
        "Read and identify main concern"
      ]
    },
    {
      "title": "Progressive Muscle Relaxation",
      "desc": "Reduces physical tension by tightening and releasing muscles.",
      "minScore": 0,
      "maxScore": 60,
      "duration": "5 mins",
      "type": "grounding",
      "benefits": "Reduces physical tension and is linked to stress relief research.",
      "steps": [
        "Tighten foot muscles (5 sec) → release",
        "Tighten legs → release",
        "Tighten hands → release",
        "Tighten shoulders → release",
        "Relax entire body"
      ]
    },
    {
      "title": "Guided Visualization",
      "desc": "Lowers stress levels by imagining a peaceful place.",
      "minScore": 0,
      "maxScore": 80,
      "duration": "3 mins",
      "type": "visualization",
      "benefits": "Lowers stress levels and uses Guided Imagery techniques.",
      "steps": [
        "Close your eyes",
        "Imagine a peaceful place",
        "Focus on sounds, colors, temperature",
        "Stay for 2–3 minutes"
      ]
    },
    {
      "title": "Emotional Check-In",
      "desc": "Builds emotional awareness and regulation.",
      "minScore": 0,
      "maxScore": 100,
      "duration": "3 mins",
      "type": "journaling",
      "benefits": "Builds emotional awareness and is related to Emotional Regulation.",
      "steps": [
        "Ask: 'What am I feeling right now?'",
        "Choose 1–2 emotions",
        "Rate intensity (1–10)",
        "Ask: 'Why do I feel this?'"
      ]
    },
    {
      "title": "Gratitude Reflection",
      "desc": "Improves mood and positivity by writing what you're grateful for.",
      "minScore": 30,
      "maxScore": 100,
      "duration": "5 mins",
      "type": "journaling",
      "benefits": "Improves mood and positivity.",
      "steps": [
        "Write 3 things you're grateful for",
        "Write why they matter",
        "Reflect for 30 seconds"
      ]
    },
    {
      "title": "Control vs Let Go",
      "desc": "Reduces unnecessary stress by focusing on what you can control.",
      "minScore": 0,
      "maxScore": 50,
      "duration": "5 mins",
      "type": "planning",
      "benefits": "Reduces unnecessary stress.",
      "steps": [
        "Write what’s stressing you",
        "Split into: Things you can control and Things you cannot",
        "Focus only on controllable actions"
      ]
    },
    {
      "title": "One-Task Focus",
      "desc": "Improves concentration by working on a single task.",
      "minScore": 30,
      "maxScore": 80,
      "duration": "10 mins",
      "type": "planning",
      "benefits": "Improves concentration and is based on Attention Control.",
      "steps": [
        "Choose one small task",
        "Set timer for 10 minutes",
        "Work only on that task",
        "Ignore distractions"
      ]
    },
    {
      "title": "'Why' Reflection",
      "desc": "Improves self-awareness by identifying root causes.",
      "minScore": 0,
      "maxScore": 70,
      "duration": "5 mins",
      "type": "journaling",
      "benefits": "Improves self-awareness by uncovering deep-rooted issues.",
      "steps": [
        "Write a problem",
        "Ask 'Why?'",
        "Repeat 5 times",
        "Identify root cause"
      ]
    },
    {
      "title": "Night Reset Routine",
      "desc": "Builds consistency and a growth mindset before bed.",
      "minScore": 0,
      "maxScore": 100,
      "duration": "5 mins",
      "type": "planning",
      "benefits": "Builds consistency and a growth mindset.",
      "steps": [
        "Write 1 thing you did well today",
        "Write 1 thing to improve",
        "Plan 1 small goal for tomorrow"
      ]
    },
    // --- Restored Original Exercises ---
    {
      "title": "Mindful Breathing",
      "desc": "Slowly breathe in and out for 3 minutes.",
      "minScore": 40,
      "maxScore": 100,
      "duration": "3 mins",
      "type": "breathing",
      "benefits": "Calms the nervous system.",
      "steps": [
        "Sit comfortably",
        "Inhale slowly",
        "Exhale fully"
      ]
    },
    {
      "title": "Daily Stretching",
      "desc": "5 minutes of full body stretches to energize.",
      "minScore": 40,
      "maxScore": 100,
      "duration": "5 mins",
      "type": "physical",
      "benefits": "Relieves muscle tension.",
      "steps": [
        "Stand up",
        "Stretch arms up",
        "Touch toes",
        "Hold for 30s"
      ]
    },
    {
      "title": "4-7-8 Breathing",
      "desc": "Inhale 4s, hold 7s, exhale 8s.",
      "minScore": 32,
      "maxScore": 39,
      "duration": "3 mins",
      "type": "breathing",
      "benefits": "Reduces anxiety and helps with sleep.",
      "steps": [
        "Inhale for 4 seconds",
        "Hold for 7 seconds",
        "Exhale for 8 seconds",
        "Repeat 4 times"
      ]
    },
    {
      "title": "Journaling",
      "desc": "Write down your thoughts freely.",
      "minScore": 32,
      "maxScore": 39,
      "duration": "5 mins",
      "type": "journaling",
      "benefits": "Clears mind and processes emotions.",
      "steps": [
        "Open journal",
        "Write without filtering",
        "Reflect on feelings"
      ]
    },
    {
      "title": "5-4-3-2-1 Grounding",
      "desc": "Name 5 things you see, 4 feel, 3 hear.",
      "minScore": 24,
      "maxScore": 31,
      "duration": "3 mins",
      "type": "grounding",
      "benefits": "Brings you back to the present moment.",
      "steps": [
        "Identify 5 things you see",
        "Identify 4 things you feel",
        "Identify 3 things you hear",
        "Identify 2 things you smell",
        "Identify 1 thing you taste"
      ]
    },
    {
      "title": "Body Relaxation",
      "desc": "Relax each muscle group slowly.",
      "minScore": 24,
      "maxScore": 31,
      "duration": "5 mins",
      "type": "grounding",
      "benefits": "Releases physical stress.",
      "steps": [
        "Lie down comfortably",
        "Focus on your toes",
        "Slowly move up relaxing each part"
      ]
    },
    {
      "title": "Calm Breathing",
      "desc": "Breathe gently and slowly for 3 minutes.",
      "minScore": 0,
      "maxScore": 23,
      "duration": "3 mins",
      "type": "breathing",
      "benefits": "Provides immediate panic relief.",
      "steps": [
        "Take a deep breath",
        "Exhale slowly",
        "Focus only on your breath"
      ]
    },
    {
      "title": "Reach Out",
      "desc": "Consider talking to someone you trust.",
      "minScore": 0,
      "maxScore": 23,
      "duration": "5 mins",
      "type": "social",
      "benefits": "Provides emotional support and connection.",
      "steps": [
        "Think of a trusted person",
        "Send them a message",
        "Share how you feel"
      ]
    }
  ];

  Future<void> _seedDatabase() async {
    for (var exercise in _seedExercises) {
      final title = exercise['title'] as String? ?? 'untitled';
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
      await _firestore.collection('exercises').doc(slug).set(exercise, SetOptions(merge: true));
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercises Seeded safely!')));
  }

  Future<void> _deleteExercise(String id) async {
    await _firestore.collection('exercises').doc(id).delete();
  }

  void _showAddEditDialog({DocumentSnapshot? doc}) {
    final isEditing = doc != null;
    final dataMap = isEditing ? doc.data() as Map<String, dynamic> : <String, dynamic>{};
    
    final titleController = TextEditingController(text: dataMap['title'] ?? '');
    final descController = TextEditingController(text: dataMap['desc'] ?? '');
    final minScoreController = TextEditingController(text: (dataMap['minScore'] ?? 0).toString());
    final maxScoreController = TextEditingController(text: (dataMap['maxScore'] ?? 100).toString());
    final durationController = TextEditingController(text: dataMap['duration'] ?? '5 mins');
    final benefitsController = TextEditingController(text: dataMap['benefits'] ?? '');
    
    String initialSteps = '';
    if (dataMap.containsKey('steps')) {
      final stepsList = dataMap['steps'] as List<dynamic>?;
      if (stepsList != null) {
         initialSteps = stepsList.map((s) {
           if (s is Map) return s['text'] ?? '';
           return s.toString();
         }).join('\n');
      }
    }
    final stepsController = TextEditingController(text: initialSteps);
    
    String selectedType = dataMap['type'] ?? 'other';
    final typeOptions = ['breathing', 'physical', 'meditation', 'grounding', 'journaling', 'music', 'visualization', 'social', 'planning', 'other'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
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
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: durationController,
                              decoration: InputDecoration(
                                labelText: 'Duration (e.g. 5 mins)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.05),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedType,
                              decoration: InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.withOpacity(0.05),
                              ),
                              items: typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => selectedType = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: benefitsController,
                        decoration: InputDecoration(
                          labelText: 'Benefits',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: stepsController,
                        decoration: InputDecoration(
                          labelText: 'Steps (One per line)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.05),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
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

                    final steps = stepsController.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                    final data = {
                      'title': title,
                      'desc': descController.text.trim(),
                      'minScore': min,
                      'maxScore': max,
                      'duration': durationController.text.trim(),
                      'type': selectedType,
                      'benefits': benefitsController.text.trim(),
                      'steps': steps,
                    };

                    try {
                      if (isEditing) {
                        await _firestore.collection('exercises').doc(doc!.id).update(data);
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
            );
          }
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
