import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/journal_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../core/widgets/primary_button.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEntryScreen({super.key, this.entry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late TextEditingController _textController;
  late TextEditingController _titleController;
  late String _selectedMood;
  List<String> _selectedTags = [];
  List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  static const Map<String, String> _moods = {
    '😄': 'Rad',
    '😊': 'Happy',
    '😐': 'Meh',
    '😔': 'Sad',
    '😢': 'Awful',
    '😡': 'Angry',
  };

  final List<String> _tags = [
    'Study', 'Exams', 'Social', 'Crushing', 'Family', 'Food', 'Travel', 'Sleep', 'Gaming', 'Music'
  ];

  static const List<String> _prompts = [
    "What's stressing you out right now?",
    "Rate your day 1-10 and explain why.",
    "Any dating updates? 👀",
    "Rant space: Let it all out.",
    "One thing you're proud of today.",
    "What's the plan for tomorrow?"
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry?.text ?? '');
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _selectedMood = widget.entry?.mood ?? _moods.keys.first;
    _selectedTags = List.from(widget.entry?.tags ?? []);
    _selectedImages = List.from(widget.entry?.images ?? []);
    
    // Ensure existing tags from the entry are in the available list
    for (final tag in _selectedTags) {
      if (!_tags.contains(tag)) {
        _tags.add(tag);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_textController.text.trim().isEmpty) return;

    final newEntry = JournalEntry(
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      text: _textController.text.trim(),
      mood: _selectedMood,
      tags: _selectedTags,
      images: _selectedImages,
      date: widget.entry?.date, 
    );

    Navigator.pop(context, {'action': 'save', 'entry': newEntry});
  }

  void _delete() {
    Navigator.pop(context, {'action': 'delete'});
  }

  void _addCustomTag() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tag name (e.g., Gym)'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (!_tags.contains(result)) {
           _tags.add(result);
        }
        if (!_selectedTags.contains(result)) {
           _selectedTags.add(result);
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  void _showprompts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Need a spark?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._prompts.map((prompt) => ListTile(
                leading: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
                title: Text(prompt),
                onTap: () {
                  Navigator.pop(context);
                  _textController.text = "$prompt\n\n${_textController.text}";
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return "${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final backgroundColor = isDark ? Colors.black : const Color(0xFFF8F9FE);
    final accentColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100, bottom: 100), // Top padding for overlay buttons
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mood & Tags Section (Context)
                    Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           // Mood Selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _moods.entries.map((entry) {
                                final isSelected = _selectedMood == entry.key;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedMood = entry.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        AnimatedScale(
                                          scale: isSelected ? 1.25 : 0.9, // More dramatic scale
                                          duration: const Duration(milliseconds: 200),
                                          child: Text(entry.key, style: const TextStyle(fontSize: 36)),
                                        ),
                                        const SizedBox(height: 8),
                                        AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: isSelected ? 1.0 : 0.0,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 4),
                                              ]
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 24),
                          
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ..._tags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedTags.remove(tag);
                                      } else {
                                        _selectedTags.add(tag);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? accentColor : Colors.transparent, 
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected ? accentColor : (isDark ? Colors.white24 : Colors.black12),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : textColor.withOpacity(0.6),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              GestureDetector(
                                onTap: _addCustomTag,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, size: 14, color: textColor.withOpacity(0.5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tag', 
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.5))
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                         ],
                       ),
                    ),
                    
                    const SizedBox(height: 32),

                    // The "Page" - Writing Area
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 100),
                      margin: const EdgeInsets.symmetric(horizontal: 0), // Full width or slight margin? Full width feels more immersive
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header (Inside Page)
                          Container(
                            padding: const EdgeInsets.only(left: 4), // Align with text
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Text(
                               _formatDate(widget.entry?.date ?? DateTime.now()).toUpperCase(),
                               style: TextStyle(
                                 color: textColor.withOpacity(0.4),
                                 fontWeight: FontWeight.w800,
                                 fontSize: 12,
                                 letterSpacing: 1.5,
                               ),
                             ),
                          ),

                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(
                              height: 140, // Slightly taller images
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 140,
                                        margin: const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: FileImage(File(_selectedImages[index])),
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 24,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black38,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Title Field
                          TextField(
                            controller: _titleController,
                            cursorColor: accentColor,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 30, // Big Title
                              fontWeight: FontWeight.w900, // Extra Bold
                              color: textColor,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Title...',
                              hintStyle: TextStyle(
                                color: textColor.withOpacity(0.15),
                                fontWeight: FontWeight.w900,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Body Field
                          TextField(
                            controller: _textController,
                            maxLines: null,
                            cursorColor: accentColor,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.8, // Relaxed Line Height
                              color: textColor.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2, // Subtle spacing
                            ),
                            decoration: InputDecoration(
                              hintText: "Start writing...",
                              hintStyle: TextStyle(
                                color: textColor.withOpacity(0.25),
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Buttons (Overlay)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Compact
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.8), // Subtle backdrop
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 24, color: textColor.withOpacity(0.6))
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                   backgroundColor: accentColor, // Filled button for prominence
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                   elevation: 4,
                   shadowColor: accentColor.withOpacity(0.4),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildBottomAction(
                 icon: Icons.image_outlined, 
                 label: 'Photo', 
                 onTap: _pickImages,
                 color: textColor
               ),
               
               Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)), // Divider

               _buildBottomAction(
                 icon: Icons.lightbulb_outline_rounded, 
                 label: 'Prompt', 
                 onTap: _showprompts,
                 color: textColor
               ),

               Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),

               _buildBottomAction(
                 icon: Icons.mic_none_rounded, 
                 label: 'Voice', 
                 onTap: () {
                   // Placeholder for voice
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice recording coming soon!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.black87, duration: Duration(milliseconds: 1500)),
                    );
                 },
                 color: textColor.withOpacity(0.5) // Dimmed as placeholder
               ),

               Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),

               if (widget.entry != null)
                 _buildBottomAction(
                   icon: Icons.delete_outline_rounded, 
                   label: 'Delete', 
                   onTap: _delete,
                   color: Colors.red
                 )
                else
                 _buildBottomAction(
                   icon: Icons.more_horiz_rounded,
                   label: 'More',
                   onTap: () {},
                   color: textColor.withOpacity(0.5)
                 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withOpacity(color.opacity > 0.5 ? 0.7 : 1.0))),
        ],
      ),
    );
  }
}

