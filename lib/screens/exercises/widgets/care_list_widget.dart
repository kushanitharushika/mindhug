import 'package:flutter/material.dart';
import '../../../models/care_item.dart';

class CareListWidget extends StatefulWidget {
  final List<CareItem> items;
  final Function(String, bool) onToggle;
  final Function(String) onDelete;
  final Function(String) onAdd;
  final Function(String, int)? onProgressUpdate;

  const CareListWidget({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
    this.onProgressUpdate,
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
                if (item.type == 'counter')
                   _buildCounterTile(item)
                else
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

  Widget _buildCounterTile(CareItem item) {
    bool isDone = item.currentProgress >= item.maxProgress;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon or Check indicator
          InkWell(
            onTap: () {
              if (isDone) {
                 widget.onProgressUpdate?.call(item.id, 0); // Reset functionality if clicked when done
              } else {
                 widget.onProgressUpdate?.call(item.id, item.maxProgress); // Quick complete
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.teal : Colors.grey.shade400,
                  width: 2,
                ),
                color: isDone ? Colors.teal : Colors.transparent,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                if (item.reminderTime != null)
                  Text(
                    "Reminder: ${item.reminderTime}",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          
          // Counter Controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, 
                  color: item.currentProgress > 0 ? Colors.teal : Colors.grey),
                onPressed: item.currentProgress > 0 && widget.onProgressUpdate != null
                    ? () => widget.onProgressUpdate!(item.id, item.currentProgress - 1)
                    : null,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                alignment: Alignment.center,
                child: Text(
                  '${item.currentProgress} / ${item.maxProgress}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                  color: !isDone ? Colors.teal : Colors.grey),
                onPressed: !isDone && widget.onProgressUpdate != null
                    ? () => widget.onProgressUpdate!(item.id, item.currentProgress + 1)
                    : null,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          )
        ],
      ),
    );
  }
}
