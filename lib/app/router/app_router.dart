import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/customer/presentation/pages/customer_dashboard_page.dart';
import '../../features/agent/presentation/pages/agent_dashboard_page.dart';
import '../../features/auth/presentation/pages/admin_kyc_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/customer',
      builder: (context, state) => const CustomerDashboardPage(),
    ),
    GoRoute(
      path: '/agent',
      builder: (context, state) => const AgentDashboardPage(),
    ),
    GoRoute(
      path: '/admin-kyc',
      builder: (context, state) => const AdminKycPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
  // TODO: Add redirect logic based on auth and role
); 