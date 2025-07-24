import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/agent_home_cubit.dart';

class AgentDashboardPage extends StatelessWidget {
  const AgentDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgentHomeCubit(
        firestore: GetIt.I<FirebaseFirestore>(),
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Agent Dashboard')),
        body: BlocBuilder<AgentHomeCubit, AgentHomeState>(
          builder: (context, state) {
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
                    Text('Available Balance: EC ${state.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
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
        ),
      ),
    );
  }
} 