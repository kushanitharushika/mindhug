import 'package:flutter/material.dart';
import '../../../models/care_item.dart';

class CareListWidget extends StatefulWidget {
  final List<CareItem> items;
  final Function(String, bool) onToggle;
  final Function(String) onDelete;
  final Function(String) onAdd;

  const CareListWidget({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<CareListWidget> createState() => _CareListWidgetState();
}

class _CareListWidgetState extends State<CareListWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isAdding = false;

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onAdd(_controller.text.trim());
      _controller.clear();
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.items.map((item) {
          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.redAccent,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => widget.onDelete(item.id),
            child: Column(
              children: [
                 CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  activeColor: Colors.teal,
                  checkboxShape: const CircleBorder(),
                  value: item.isCompleted,
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      color: item.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: item.description.isNotEmpty ? 
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey.shade500),
                    ) : null,
                  onChanged: (val) {
                    widget.onToggle(item.id, val ?? false);
                  },
                ),
                if (item != widget.items.last) 
                   Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey.withOpacity(0.1)),
              ],
            ),
          );
        }),
        
        // Add Button / Input
        if (_isAdding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Add custom care item...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.teal),
                  onPressed: _submit,
                ),
                 IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isAdding = false;
                      _controller.clear();
                    });
                  },
                ),
              ],
            ),
          )
        else
          ListTile(
            leading: const Icon(Icons.add, color: Colors.teal),
            title: const Text(
              "Add your own",
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setState(() {
                _isAdding = true;
              });
            },
          ),
      ],
    );
  }
}
