import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
// TODO: Import customer, agent, admin dashboard pages

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    // TODO: Add customer dashboard route
    // TODO: Add agent dashboard route
    // TODO: Add admin dashboard route
  ],
  // TODO: Add redirect logic based on auth and role
); 