import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/customer_home_cubit.dart';
import 'send_money_page.dart';
import 'transaction_history_page.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerHomeCubit(
        firestore: GetIt.I<FirebaseFirestore>(),
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
            ),
          ],
        ),
        body: BlocBuilder<CustomerHomeCubit, CustomerHomeState>(
          builder: (context, state) {
            final authState = context.watch<AuthCubit>().state;
            String userInfo = '';
            if (authState is AuthAuthenticated) {
              userInfo = authState.user.email ?? authState.user.displayName ?? '';
            }
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Welcome, $userInfo', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  Text('Wallet Balance', style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.showBalance ? ' EC ${state.balance.toStringAsFixed(2)}' : '****',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(state.showBalance ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => context.read<CustomerHomeCubit>().toggleBalanceVisibility(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Transaction History'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SendMoneyPage()),
            );
          },
          child: const Icon(Icons.send),
          tooltip: 'Send Money',
        ),
      ),
    );
  }
} 