import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Fixed: was 2000 seconds!

    if (!mounted) return;

    final storageService = context.read<StorageService>();
    final hasCompletedOnboarding = !storageService.isFirstLaunch();
    final isAuthenticated = storageService.getToken() != null;

    if (!hasCompletedOnboarding) {
      context.go('/onboarding');
    } else if (!isAuthenticated) {
      context.go('/auth');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF)
            ], // blue-600 to blue-800
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Zap Icon - matches React motion effects
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: const Icon(
                        Icons.flash_on,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'PowerAlert GH',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Community Power Monitoring',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
