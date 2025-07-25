import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String email = '';
    String role = '';
    String? uid;
    if (authState is AuthAuthenticated) {
      email = authState.user.email ?? '';
      role = authState.user.role ?? '';
      uid = authState.user.id;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile / Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            const SizedBox(height: 8),
            Text('Role: $role'),
            const SizedBox(height: 8),
            if (uid != null)
              FutureBuilder<DocumentSnapshot>(
                future: GetIt.I<FirebaseFirestore>().collection('users').doc(uid).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('KYC Status: ...');
                  final kyc = (snapshot.data!.data() as Map<String, dynamic>?)?['kyc'] ?? {};
                  final kycStatus = kyc['status'] ?? 'none';
                  return Text('KYC Status: $kycStatus');
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Change Password'),
                    content: const Text('Password change is not implemented in this demo.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // For demo, just show a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contact Admin'),
                    content: const Text('Contact admin at: admin@example.com'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Contact Admin'),
            ),
          ],
        ),
      ),
    );
  }
} 