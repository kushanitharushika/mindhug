import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<String> _entries = [];

  void _addEntry() async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        String value = '';
        return AlertDialog(
          title: const Text('New Journal Entry'),
          content: TextField(
            autofocus: true,
            maxLines: 4,
            onChanged: (v) => value = v,
            decoration: const InputDecoration(hintText: 'Write something...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (text != null && text.trim().isNotEmpty) {
      setState(() => _entries.insert(0, text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Journal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No entries yet',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addEntry,
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Write your first entry'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(entry),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
