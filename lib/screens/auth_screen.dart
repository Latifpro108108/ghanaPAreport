import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_isLogin) {
      if (_phoneController.text.isEmpty) {
        _showMessage('Please enter phone number');
        return;
      }
      _handleLogin();
    } else {
      if (_nameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _emailController.text.isEmpty) {
        _showMessage('Please fill all fields');
        return;
      }
      _handleRegister();
    }
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final storageService = context.read<StorageService>();
    await storageService.setAuthenticated(true);
    await storageService.saveToken('mock_token_123');

    if (mounted) {
      context.go('/home');
    }
  }

  void _handleRegister() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final storageService = context.read<StorageService>();
    await storageService.saveUserName(_nameController.text);
    await storageService.saveUserPhone(_phoneController.text);
    await storageService.saveUserEmail(_emailController.text);

    _showMessage('${AppStrings.verificationCodeSent}');

    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/otp', extra: _phoneController.text);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.flash_on,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isLogin
                          ? AppStrings.welcomeBack
                          : AppStrings.joinCommunity,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Form Container
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Mode Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeButton(
                              label: AppStrings.login,
                              isActive: _isLogin,
                              onTap: () => setState(() => _isLogin = true),
                            ),
                          ),
                          Expanded(
                            child: _buildModeButton(
                              label: AppStrings.register,
                              isActive: !_isLogin,
                              onTap: () => setState(() => _isLogin = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Form Fields
                    if (!_isLogin)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppStrings.fullName),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    _buildLabel(AppStrings.phoneNumber),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '501231234',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (!_isLogin)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppStrings.email),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'email@example.com',
                            icon: Icons.mail,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildLabel(AppStrings.password),
                          _buildTextField(
                            controller: _passwordController,
                            hint: '••••••••',
                            icon: Icons.lock,
                            obscure: true,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.primary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isLogin
                                    ? AppStrings.login
                                    : AppStrings.register,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
  }

  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
    );
  }
}
