import 'package:flutter/material.dart';
import '../../../models/care_item.dart';

class CareListWidget extends StatelessWidget {
  final List<CareItem> items;
  final Function(String, bool) onToggle;

  const CareListWidget({
    super.key,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Column(
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
                onToggle(item.id, val ?? false);
              },
            ),
            if (item != items.last) 
               Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey.withOpacity(0.1)),
          ],
        );
      }).toList(),
    );
  }
}
