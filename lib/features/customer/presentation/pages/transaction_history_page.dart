import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/transaction_history_cubit.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionHistoryCubit(
        firestore: GetIt.I<FirebaseFirestore>(),
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Transaction History')),
        body: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
          builder: (context, state) {
            if (state is TransactionHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionHistoryError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is TransactionHistoryLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(child: Text('No transactions found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = state.transactions[index];
                  final type = tx['type'] ?? '';
                  final amount = tx['amount'] ?? 0.0;
                  final date = (tx['timestamp'] as Timestamp?)?.toDate();
                  return ListTile(
                    leading: Icon(type == 'send' ? Icons.arrow_upward : Icons.arrow_downward, color: type == 'send' ? Colors.red : Colors.green),
                    title: Text('${type == 'send' ? 'Sent' : 'Received'} EC $amount'),
                    subtitle: date != null ? Text('${date.toLocal()}') : null,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 