import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
import '../../models/journal_entry.dart';
import 'journal_entry_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // _entries managed by StreamBuilder now

  @override
  void initState() {
    super.initState();
  }

  void _addEntry() async {
    final result = await _openEntryScreen();
    if (result != null && result['action'] == 'save') {
       final entry = result['entry'] as JournalEntry;
       
       try {
         final user = FirebaseAuth.instance.currentUser;
         if (user != null) {
           await FirebaseFirestore.instance.collection('journal').add({
             ...entry.toJson(),
             'userId': user.uid,
             'date': DateTime.now().toIso8601String(), // Ensure current time
           });
         }
       } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
         }
       }
    }
  }

  void _editEntry(JournalEntry entry) async {
    final result = await _openEntryScreen(existingEntry: entry);
    
    if (result != null) {
      if (result['action'] == 'save') {
        final updatedEntry = result['entry'] as JournalEntry;
        if (entry.id != null) {
          await FirebaseFirestore.instance.collection('journal').doc(entry.id).update(updatedEntry.toJson());
        }
      } else if (result['action'] == 'delete') {
         if (entry.id != null) {
           await FirebaseFirestore.instance.collection('journal').doc(entry.id).delete();
         }
      }
    }
  }

  Future<Map<String, dynamic>?> _openEntryScreen({JournalEntry? existingEntry}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEntryScreen(entry: existingEntry),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return "${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}";
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF121212) : Colors.purple.shade50;
    
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        toolbarHeight: 90,
        elevation: 0,
        title: const MindHugLogo(size: 40),
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121212), Colors.black],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.white],
                ),
        ),
        child: user == null 
           ? const Center(child: Text("Please login"))
           : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journal')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  // Check for index error
                  if (error.contains('failed-precondition') || error.contains('requires an index')) {
                     WidgetsBinding.instance.addPostFrameCallback((_) {
                       if (context.mounted) {
                         ScaffoldMessenger.of(context).hideCurrentSnackBar();
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Action Required: Create Firestore Index. Check debug console for link."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 10),
                            ),
                         );
                       }
                     });
                     debugPrint("PLEASE CREATE INDEX: $error");
                  }
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Error: $error", textAlign: TextAlign.center),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                debugPrint("JOURNAL DEBUG: User ID = ${user.uid}");
                debugPrint("JOURNAL DEBUG: Found ${docs.length} documents");
                
                if (snapshot.hasError) debugPrint("JOURNAL DEBUG: Error = ${snapshot.error}");

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.book_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                         const SizedBox(height: 16),
                         Text(
                           'Your Journal is Empty',
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: subTextColor),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           'Tap + to start writing',
                           style: TextStyle(fontSize: 14, color: subTextColor),
                         ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: docs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24, left: 8),
                          child: Text(
                            'Journal',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      }

                      final doc = docs[index - 1];
                      final entry = JournalEntry.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _editEntry(entry),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Section
                                if (entry.images.isNotEmpty) ...[
                                  SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: entry.images.length == 1 
                                        ? Image(
                                            image: _getImageProvider(entry.images.first),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (c, o, s) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: Image(
                                                  image: _getImageProvider(entry.images[0]), 
                                                  fit: BoxFit.cover, 
                                                  height: double.infinity,
                                                  errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                                                )
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Image(
                                                  image: _getImageProvider(entry.images[1]), 
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  errorBuilder: (c, o, s) => Container(color: Colors.grey[300]),
                                                )
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                ],

                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       // Mood & Tags Row
                                       if (entry.mood.isNotEmpty || entry.tags.isNotEmpty)
                                        Row(
                                          children: [
                                            Text(entry.mood, style: const TextStyle(fontSize: 20)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: entry.tags.map((tag) => Container(
                                                    margin: const EdgeInsets.only(right: 6),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isDark ? Colors.white10 : Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      tag,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: isDark ? Colors.white70 : Colors.black87,
                                                      ),
                                                    ),
                                                  )).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      
                                      const SizedBox(height: 12),

                                      if (entry.title != null) ...[
                                        Text(
                                          entry.title!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      
                                      Text(
                                        entry.text,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: subTextColor,
                                          height: 1.5,
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                      
                                      Row(
                                        children: [
                                          Text(
                                            _formatDate(entry.date),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
