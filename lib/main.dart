import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/districts_screen.dart';
import 'screens/district_detail_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatefulWidget {
  final StorageService storageService;

  const MyApp({Key? key, required this.storageService}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Page Not Found',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'The page you are looking for does not exist.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: '/',
          name: 'root',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/otp',
          name: 'otp',
          builder: (context, state) {
            final phoneNumber = state.extra as String?;
            return OTPVerificationScreen(phoneNumber: phoneNumber ?? '');
          },
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/districts',
          name: 'districts',
          builder: (context, state) => const DistrictsScreen(),
        ),
        GoRoute(
          path: '/district/:id',
          name: 'districtDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return DistrictDetailScreen(districtId: id);
          },
        ),
        GoRoute(
          path: '/alerts',
          name: 'alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: widget.storageService),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTextStyles.headingSmall,
            iconTheme: IconThemeData(color: AppColors.onSurface),
          ),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
