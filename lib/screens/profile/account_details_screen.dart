import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _avatarPath;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await LocalStorage.getUserProfile();
    setState(() {
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _avatarPath = data['avatar'];
      if (_avatarPath != null && _avatarPath!.isEmpty) {
        _avatarPath = null;
      }
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate network delay for effect
    await Future.delayed(const Duration(milliseconds: 800));

    await LocalStorage.saveUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarPath: _avatarPath,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true); // Return true to indicate update
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return AppScaffold(
      showLogo: false,
      child: Column(
        children: [
          // Custom AppBar
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Account Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance back button
            ],
          ),
          const SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.purple.shade100,
                            backgroundImage: _avatarPath != null && File(_avatarPath!).existsSync()
                                ? FileImage(File(_avatarPath!))
                                : null,
                            child: _avatarPath == null
                                ? Icon(Icons.person, size: 60, color: Colors.purple.shade300)
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'john@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.contains('@') ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1 234 567 8900',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 40),

                    PrimaryButton(
                      label: 'Save Changes',
                      onPressed: _saveData,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
