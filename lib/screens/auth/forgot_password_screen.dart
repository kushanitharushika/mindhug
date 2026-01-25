import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isPhoneMode = false; // Toggle between Email and Phone
  bool _codeSent = false; // State for Phone flow
  String? _verificationId;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- Email Flow ---
  Future<void> _handleResetPasswordEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSuccessDialog(
        "Check your email",
        "If this email is registered, a password reset link has been sent 💌",
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Phone Flow ---
  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _showMessage("OTP Sent! 📩");
        },
        onVerificationFailed: (e) {
           if (!mounted) return;
           setState(() => _isLoading = false);
           _showMessage("Verification Failed: ${e.message}");
        },
        onVerificationCompleted: (credential) async {
           // Auto-retrieval or instant verification
           await _signInWithCredential(credential);
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          if (!mounted) return;
           setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage("Error: $e");
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage("Please enter a valid 6-digit OTP");
      return;
    }
    
    if (_verificationId == null) return;

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage("Invalid OTP or Error: $e");
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
     try {
       await _authService.signInWithPhoneCredential(credential);
       if (!mounted) return;
       // Navigate to Home/Dashboard and clear stack
       Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); 
     } catch (e) {
       if (!mounted) return;
       setState(() => _isLoading = false);
       _showMessage("Login Failed: $e");
     }
  }

  // --- Helpers ---
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isPhoneMode 
                  ? "Enter your phone number to receive an OTP." 
                  : "Enter your email for a reset link.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              
              const SizedBox(height: 24),

              // Toggle
              Row(
                children: [
                   Expanded(
                     child: _TabButton(
                       text: "Email",
                       isSelected: !_isPhoneMode,
                       onTap: () => setState(() {
                         _isPhoneMode = false;
                         _codeSent = false;
                       }),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: _TabButton(
                       text: "Phone (OTP)",
                       isSelected: _isPhoneMode,
                       onTap: () => setState(() {
                         _isPhoneMode = true;
                         // _codeSent remains false initially
                       }),
                     ),
                   ),
                ],
              ),
              
              const SizedBox(height: 32),

              if (!_isPhoneMode) ...[
                // --- Email UI ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButton(
                  text: "Send Reset Link",
                  isLoading: _isLoading,
                  onPressed: _handleResetPasswordEmail,
                ),

              ] else if (!_codeSent) ...[
                // --- Phone Input UI ---
                 TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number (e.g. +1...)",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButton(
                  text: "Get OTP",
                  isLoading: _isLoading,
                  onPressed: _handleSendOtp,
                ),

              ] else ...[
                 // --- OTP Input UI ---
                 Text(
                   "Enter 6-digit code sent to ${_phoneController.text}",
                   textAlign: TextAlign.center,
                   style: const TextStyle(fontWeight: FontWeight.w500),
                 ),
                 const SizedBox(height: 16),
                 Pinput(
                   controller: _otpController,
                   length: 6,
                   defaultPinTheme: PinTheme(
                     width: 56,
                     height: 56,
                     textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.purple.shade200),
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                 ),
                 const SizedBox(height: 24),
                 _ActionButton(
                   text: "Verify & Login",
                   isLoading: _isLoading,
                   onPressed: _handleVerifyOtp,
                 ),
                 TextButton(
                   onPressed: () => setState(() => _codeSent = false),
                   child: const Text("Change Phone Number"),
                 ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _TabButton({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.purple : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
