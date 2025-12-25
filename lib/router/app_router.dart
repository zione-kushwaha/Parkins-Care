import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkins_care/feature/dashboard/presentation/pages/home.dart';
import '../feature/auth/presentation/pages/forgot_password_screen.dart';
import '../feature/auth/presentation/pages/sign_in_screen.dart';
import '../feature/auth/presentation/pages/sign_up_screen.dart';
import '../feature/medication/presentation/pages/medications_screen.dart';
import '/router/splash_screen.dart';
import '../core/constants/app_routes.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash & Onboarding
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Dashboard
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomeScreen()
      ),

      // Medication Routes
      GoRoute(
        path: AppRoutes.medications,
        builder: (context, state) => const MedicationsScreen(),
      ),

    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
