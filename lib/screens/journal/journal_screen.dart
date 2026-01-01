import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class JournalEntry {
  final String text;
  final String mood;
  final DateTime date;

  JournalEntry({required this.text, required this.mood, DateTime? date})
    : date = date ?? DateTime.now();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = [];

  static const List<String> _moodOptions = [
    '😄',
    '😊',
    '🙂',
    '😐',
    '😔',
    '😢',
    '😡',
  ];

  void _addEntry() async {
    final result = await showDialog<JournalEntry?>(
      context: context,
      builder: (context) {
        String value = '';
        String selectedMood = _moodOptions[1];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text('New Journal Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    maxLines: 4,
                    autofocus: true,
                    onChanged: (v) => value = v,
                    decoration: InputDecoration(
                      hintText: 'Write what’s on your mind...',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How do you feel today?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _moodOptions.map((m) {
                      final isSelected = selectedMood == m;
                      return GestureDetector(
                        onTap: () => setState(() => selectedMood = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.purple.shade100
                                : Colors.transparent,
                          ),
                          child: Text(m, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (value.trim().isEmpty) {
                      Navigator.pop(context);
                      return;
                    }
                    Navigator.pop(
                      context,
                      JournalEntry(text: value.trim(), mood: selectedMood),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _entries.insert(0, result));
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const MindHugLogo(size: 40),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF121212), Colors.black],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.white],
                ),
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 30),
          children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Journal',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      ),
                  ),
                  IconButton(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add_circle, color: Colors.purple, size: 30),
                    tooltip: 'New entry',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'A safe space for your thoughts',
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 24),

              if (_entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 60,
                          color: Colors.purple.shade200,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No journal entries yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: subTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _addEntry,
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Write your first entry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _entries.length,
                  // ignore: unnecessary_underscores
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark ? Colors.purple.withOpacity(0.2) : Colors.purple.shade50,
                                      ),
                                      child: Text(
                                        entry.mood,
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _formatDate(entry.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => setState(
                                    () => _entries.removeAt(index),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              entry.text,
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
        ),
      ),
    );
  }
}
