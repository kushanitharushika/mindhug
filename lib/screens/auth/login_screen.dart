import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../widgets/mindhug_logo.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  late final AnimationController _animController;
  late final Animation<double> _floating;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _floating = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animController.forward();
    _animController.repeat(reverse: true);
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final isRemembered = prefs.getBool('remember_me') ?? false;

    if (mounted && isRemembered && savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        if (savedPassword != null) {
          _passwordController.text = savedPassword;
        }
        rememberMe = true;
      });
    }
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Save or Clear Preferences
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final surfaceColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.backgroundDark, Colors.black],
                    )
                  : AppColors.bgGradient,
            ),
          ),
          
          // Decorative Elements
          Positioned(
            right: -50,
            top: -50,
            child: AnimatedBuilder(
              animation: _floating,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floating.value),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 41, // Avoid sub-pixel overflow
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(), // Flexible space top
                              
                              // Header
                              Row(
                                children: [
                                  const MindHugLogo(size: 48),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // Help action
                                    },
                                    child: const Text('Need Help?'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Welcome Text
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue your mental wellness journey',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: subTextColor,
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Login Form
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.05),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: 'Email',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _emailController,
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextField(
                                      label: 'Password',
                                      prefixIcon: Icons.lock_outlined,
                                      obscureText: !_isPasswordVisible,
                                      controller: _passwordController,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Remember & Forgot
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: rememberMe,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                activeColor: AppColors.primary,
                                                onChanged: (v) => setState(() => rememberMe = v ?? false),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Remember me',
                                              style: TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordScreen(),
                                            ),
                                          ),
                                          child: const Text('Forgot Password?'),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    if (_isLoading)
                                      const CircularProgressIndicator()
                                    else
                                      SizedBox(
                                        width: double.infinity,
                                        child: PrimaryButton(
                                          label: 'Login',
                                          onPressed: _handleLogin,
                                        ),
                                      ),
                                  ],
                                ),
                              ),const SizedBox(height: 24),
                              
                              const Spacer(), // Flexible space middle
                              
                              // Social Login
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade200)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Or continue with',
                                      style: TextStyle(color: subTextColor),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade200)),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialButton('assets/icons/google.png', Icons.g_mobiledata, isDark),
                                  const SizedBox(width: 16),
                                  _socialButton('assets/icons/facebook.png', Icons.facebook, isDark),
                                ],
                              ),
                              
                              const Spacer(), // Flexible space bottom
                              
                              // Signup Link
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(color: textColor),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      ),
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String assetPath, IconData fallbackIcon, bool isDark) {
    // Note: In real app use SVG or Image.asset
    // for now using icons with premium container styling
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          fallbackIcon,
          size: 28,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
