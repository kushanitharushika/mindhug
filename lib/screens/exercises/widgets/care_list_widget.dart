import 'package:flutter/material.dart';
import '../../../models/care_item.dart';

class CareListWidget extends StatefulWidget {
  final List<CareItem> items;
  final Function(String, bool) onToggle;
  final Function(String) onDelete;
  final Function(CareItem) onAdd;
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
  Future<void> _showAddTaskDialog([CareItem? existingItem]) async {
    String title = existingItem?.title ?? "";
    String description = existingItem?.description ?? "";
    String type = existingItem?.type ?? "checkbox"; // 'checkbox' or 'counter'
    int target = existingItem?.maxProgress ?? 1;
    
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    if (existingItem?.startTime != null) {
      try {
        final parts = existingItem!.startTime!.replaceAll(RegExp(r'[A-Za-z\s]'), '').split(':');
        int h = int.parse(parts[0]);
        if (existingItem.startTime!.contains("PM") && h != 12) h += 12;
        if (existingItem.startTime!.contains("AM") && h == 12) h = 0;
        startTime = TimeOfDay(hour: h, minute: int.parse(parts[1]));
      } catch (_) {}
    }
    
    if (existingItem?.endTime != null) {
      try {
        final parts = existingItem!.endTime!.replaceAll(RegExp(r'[A-Za-z\s]'), '').split(':');
        int h = int.parse(parts[0]);
        if (existingItem.endTime!.contains("PM") && h != 12) h += 12;
        if (existingItem.endTime!.contains("AM") && h == 12) h = 0;
        endTime = TimeOfDay(hour: h, minute: int.parse(parts[1]));
      } catch (_) {}
    }
    
    final bool isFixedItem = existingItem != null && !existingItem.isDeletable;
    final int minAllowedTarget = isFixedItem ? existingItem.minTarget : 1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : Colors.black87;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_task, color: Colors.teal),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            existingItem == null ? "New Care Task" : "Edit Care Task",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title Input
                      TextField(
                        controller: TextEditingController(text: title),
                        enabled: !isFixedItem,
                        decoration: InputDecoration(
                          labelText: "Task Title",
                          prefixIcon: const Icon(Icons.title, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) => title = val,
                      ),
                      const SizedBox(height: 16),

                      // Description Input
                      TextField(
                        controller: TextEditingController(text: description),
                        enabled: !isFixedItem,
                        decoration: InputDecoration(
                          labelText: "Description (optional)",
                          prefixIcon: const Icon(Icons.notes, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) => description = val,
                      ),
                      const SizedBox(height: 24),

                      // Task Type Selection
                      Text("Task Type", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: isFixedItem ? null : () => setDialogState(() => type = 'checkbox'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: type == 'checkbox' ? Colors.teal : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text("Check-off", style: TextStyle(color: type == 'checkbox' ? Colors.white : textColor, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: isFixedItem ? null : () => setDialogState(() => type = 'counter'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: type == 'counter' ? Colors.teal : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text("Counter", style: TextStyle(color: type == 'counter' ? Colors.white : textColor, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Counter Specific Settings
                      if (type == 'counter') ...[
                        Text("Daily Target", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: target > minAllowedTarget ? Colors.teal : Colors.grey),
                                onPressed: () => setDialogState(() {
                                  if (target > minAllowedTarget) target--;
                                }),
                              ),
                              Text(
                                "$target",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                                onPressed: () => setDialogState(() => target++),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Text("Reminder Period", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                                  if (time != null) setDialogState(() => startTime = time);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(startTime?.format(context) ?? "Start", style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
                                  if (time != null) setDialogState(() => endTime = time);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.nights_stay_outlined, size: 16, color: Colors.indigo),
                                      const SizedBox(width: 8),
                                      Text(endTime?.format(context) ?? "End", style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text("Cancel", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (title.trim().isEmpty) return;
                                
                                String? startStr;
                                String? endStr;
                                if (startTime != null && endTime != null) {
                                  startStr = startTime!.format(context);
                                  endStr = endTime!.format(context);
                                }

                                final newItem = CareItem(
                                  id: existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: title.trim(),
                                  description: isFixedItem && type == 'counter' ? "$target glasses today 💧" : description.trim(),
                                  type: type,
                                  maxProgress: type == 'counter' ? target : 1,
                                  minTarget: minAllowedTarget,
                                  isDeletable: existingItem?.isDeletable ?? true,
                                  currentProgress: existingItem?.currentProgress ?? 0,
                                  isCompleted: existingItem?.isCompleted ?? false,
                                  startTime: startStr,
                                  endTime: endStr,
                                  reminderTime: (startStr != null && endStr != null) ? "$startStr - $endStr" : null,
                                );
                                
                                widget.onAdd(newItem);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text("Save Task", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.items.map((item) {
          Widget listTile = Column(
            children: [
              if (item.type == 'counter')
                 _buildCounterTile(item)
              else
                 CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  activeColor: Colors.teal,
                  checkboxShape: const CircleBorder(),
                  value: item.isCompleted,
                  secondary: IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () => _showAddTaskDialog(item),
                  ),
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
          );

          if (!item.isDeletable) {
            return listTile;
          }

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
            child: listTile,
          );
        }),
        
        ListTile(
          leading: const Icon(Icons.add, color: Colors.teal),
          title: const Text(
            "Add your own",
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: _showAddTaskDialog,
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
                Row(
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
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showAddTaskDialog(item),
                      child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                if (item.reminderTime != null)
                  Text(
                    item.type == 'counter' && item.startTime != null ? "Period: ${item.startTime} - ${item.endTime}" : "Reminder: ${item.reminderTime}",
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
