import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/agent_home_cubit.dart';
import '../../data/repositories/agent_repository.dart';
import 'kyc_page.dart'; // Added import for KYCPage
import 'package:go_router/go_router.dart'; // Added import for GoRouter

class AgentDashboardPage extends StatefulWidget {
  const AgentDashboardPage({Key? key}) : super(key: key);

  @override
  State<AgentDashboardPage> createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgentHomeCubit(
        repository: GetIt.I<AgentRepository>(),
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile/Settings',
              onPressed: () => GoRouter.of(context).go('/profile'),
            ),
          ],
        ),
        body: BlocBuilder<AgentHomeCubit, AgentHomeState>(
          builder: (context, state) {
            final authState = context.read<AuthCubit>().state;
            String? uid;
            if (authState is AuthAuthenticated) {
              uid = authState.user.id;
            }
            return Column(
              children: [
                if (uid != null)
                  FutureBuilder<DocumentSnapshot>(
                    future: GetIt.I<FirebaseFirestore>().collection('users').doc(uid).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final kyc = (snapshot.data!.data() as Map<String, dynamic>?)?['kyc'] ?? {};
                      final status = kyc['status'] ?? 'none';
                      if (status == 'pending') {
                        return Container(
                          width: double.infinity,
                          color: Colors.orange.shade100,
                          padding: const EdgeInsets.all(12),
                          child: const Text('KYC Status: Pending. Your documents are under review.', style: TextStyle(color: Colors.orange)),
                        );
                      } else if (status == 'rejected') {
                        return Container(
                          width: double.infinity,
                          color: Colors.red.shade100,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Expanded(child: Text('KYC Status: Rejected. Please resubmit your documents.', style: TextStyle(color: Colors.red))),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const KYCPage()),
                                  );
                                },
                                child: const Text('Resubmit KYC'),
                              ),
                            ],
                          ),
                        );
                      } else if (status == 'approved') {
                        return Container(
                          width: double.infinity,
                          color: Colors.green.shade100,
                          padding: const EdgeInsets.all(12),
                          child: const Text('KYC Status: Approved.', style: TextStyle(color: Colors.green)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                if (state is AgentHomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AgentHomeError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is AgentHomeLoaded) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Available Balance: ',
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              showBalance
                                  ? 'EC ${state.balance.toStringAsFixed(2)}'
                                  : '****',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(showBalance ? Icons.visibility : Icons.visibility_off),
                              tooltip: showBalance ? 'Hide Balance' : 'Show Balance',
                              onPressed: () {
                                setState(() {
                                  showBalance = !showBalance;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Pending Requests:', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: state.requests.isEmpty
                              ? const Center(child: Text('No pending requests.'))
                              : ListView.separated(
                                  itemCount: state.requests.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final req = state.requests[index];
                                    return Card(
                                      child: ListTile(
                                        title: Text('${req['type']} - EC ${req['amount']}'),
                                        subtitle: Text('User: ${req['userId']}\nNote: ${req['note'] ?? ''}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check, color: Colors.green),
                                              tooltip: 'Accept',
                                              onPressed: () => context.read<AgentHomeCubit>().updateRequestStatus(req['id'], 'accepted'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, color: Colors.red),
                                              tooltip: 'Decline',
                                              onPressed: () => context.read<AgentHomeCubit>().updateRequestStatus(req['id'], 'declined'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.done_all, color: Colors.blue),
                                              tooltip: 'Mark Complete',
                                              onPressed: () => context.read<AgentHomeCubit>().updateRequestStatus(req['id'], 'completed'),
                                            ),
                                          ],
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
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
} 