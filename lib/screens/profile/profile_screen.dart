import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../widgets/mindhug_logo.dart';
import '../quiz/mental_health_quiz.dart';
import '../../core/storage/local_storage.dart';
import 'account_details_screen.dart';
import '../../services/auth_service.dart';
import '../auth/auth_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/admin_dashboard.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = '';
  String? _avatarPath;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Initialize with Auth data if available
        if (mounted) {
          setState(() {
            if (_name == 'Loading...' && user.displayName != null) {
               _name = user.displayName!;
            }
            if (_email.isEmpty && user.email != null) {
               _email = user.email!;
            }
          });
        }

        final role = await AuthService().getUserRole();
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (doc.exists && mounted) {
           final data = doc.data()!;
           setState(() {
             _name = data['Name'] ?? user.displayName ?? 'MindHug User';
             _email = data['Email'] ?? user.email ?? '';
             _isAdmin = role == 'admin';
             _avatarPath = data['Avatar'] ?? user.photoURL;
           });
        }
      } else {
        // Fallback to local storage if not logged in (legacy support)
        final data = await LocalStorage.getUserProfile();
        if (mounted) {
          setState(() {
            _name = data['name'] ?? 'Guest';
            _email = data['email'] ?? '';
            _avatarPath = data['avatar'];
            if (_avatarPath != null && _avatarPath!.isEmpty) {
              _avatarPath = null;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF121212) : Colors.purple.shade50;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        toolbarHeight: 90,
        elevation: 0,
        centerTitle: false,
        title: const MindHugLogo(size: 40),
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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          children: [
              
              // Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _getAvatarImage(),
                      child: _avatarPath == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                    ),
                    Text(
                      _email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: subTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Main Actions Grid
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'Redo Wellbeing\nCheck',
                      icon: Icons.refresh_rounded, // Assuming material icons
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MentalHealthQuiz()),
                        );
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      title: 'Crisis\nHelpline',
                      icon: Icons.phone_in_talk,
                      color: AppColors.error,
                      onTap: () {
                        // Show helplines
                        _showHelplineDialog(context);
                      },
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Settings Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'General',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                     _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: isDark,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          ThemeManager.instance.toggleTheme(val);
                        },
                      ),
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Account Details',
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
                        );
                        if (updated == true) {
                          _loadProfile();
                        }
                      },
                      isDark: isDark,
                    ),
                    const Divider(height: 1),
                    if (_isAdmin) ...[
                      _SettingsTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin Dashboard',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboard()),
                          );
                        },
                        isDark: isDark,
                      ),
                      const Divider(height: 1),
                    ],
                      _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        _showNotificationSettings(context, isDark);
                      },
                      isDark: isDark,
                    ),
                     const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Privacy & Security',
                      onTap: () {},
                       isDark: isDark,
                    ),
                     const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About MindHug',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("About MindHug"),
                            content: const Text(
                              "MindHug is a supportive space designed to help you track your well-being, understand your emotions, and take small steps towards feeling better. \n\nWe use principles from Cognitive Behavioral Therapy (CBT) to help you recognize patterns and build resilience.",
                              style: TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))
                            ],
                          ),
                        );
                      },
                       isDark: isDark,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Logout
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                     await AuthService().signOut();
                     if (context.mounted) {
                       Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (_) => const AuthWrapper()), 
                        (route) => false,
                      );
                     }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
        ),
      ),
    );
  }

  void _showHelplineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crisis Helplines'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('National Helpline'),
              subtitle: Text('1-800-273-TALK (8255)'),
            ),
             ListTile(
              leading: Icon(Icons.message, color: Colors.blue),
              title: Text('Crisis Text Line'),
              subtitle: Text('Text HOME to 741741'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _showNotificationSettings(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<bool>(
              future: LocalStorage.getNotificationPreference(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                
                bool isEnabled = snapshot.data!;

                return AlertDialog(
                  title: const Text("Notifications"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text("Hourly Reminders"),
                        subtitle: const Text("Get gentle reminders to check your mood."),
                        value: isEnabled,
                        onChanged: (value) async {
                          if (value) {
                             bool granted = await NotificationService().requestPermissions();
                             if (granted) {
                               await NotificationService().scheduleHourlyNotification(
                                 id: 1, 
                                 title: "Time for a MindHug?", 
                                 body: "Take a moment to check in with yourself."
                               );
                               await LocalStorage.saveNotificationPreference(true);
                               setDialogState(() {});
                             } else {
                               if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Permission denied")),
                               );
                               }
                             }
                          } else {
                            await NotificationService().cancelAll();
                            await LocalStorage.saveNotificationPreference(false);
                            setDialogState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                           await NotificationService().showInstantNotification(
                             id: 99, 
                             title: "Test Notification", 
                             body: "This is how your MindHug reminders will look!"
                           );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text("Send Test Notification"),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                );
              }
            );
          },
        );
      },
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_avatarPath == null) return null;
    if (_avatarPath!.startsWith('http')) {
      return NetworkImage(_avatarPath!);
    }
    final file = File(_avatarPath!);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white70 : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white38 : Colors.grey.shade400,
      ),
    );
  }
}
