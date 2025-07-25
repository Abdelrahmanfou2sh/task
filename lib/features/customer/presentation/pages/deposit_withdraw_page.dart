import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/deposit_withdraw_cubit.dart';

class DepositWithdrawPage extends StatefulWidget {
  const DepositWithdrawPage({Key? key}) : super(key: key);

  @override
  State<DepositWithdrawPage> createState() => _DepositWithdrawPageState();
}

class _DepositWithdrawPageState extends State<DepositWithdrawPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _depositAmountController = TextEditingController();
  final _depositNoteController = TextEditingController();
  final _withdrawAmountController = TextEditingController();
  final _withdrawNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<DepositWithdrawCubit>(),
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            final authState = context.read<AuthCubit>().state;
            String? userId;
            if (authState is AuthAuthenticated) {
              userId = authState.user.id;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Deposit / Withdraw'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Deposit'),
                    Tab(text: 'Withdraw'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildForm(context, 'deposit', userId),
                  _buildForm(context, 'withdraw', userId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, String type, String? userId) {
    final isDeposit = type == 'deposit';
    final amountController = isDeposit ? _depositAmountController : _withdrawAmountController;
    final noteController = isDeposit ? _depositNoteController : _withdrawNoteController;
    return BlocConsumer<DepositWithdrawCubit, DepositWithdrawState>(
      listener: (context, state) {
        if (state is DepositWithdrawSuccess) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Request Submitted'),
              content: Text('Your $type request has been submitted.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          amountController.clear();
          noteController.clear();
        } else if (state is DepositWithdrawError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit request: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final loading = state is DepositWithdrawLoading;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (userId != null && !loading)
                    ? () {
                        final amount = double.tryParse(amountController.text.trim());
                        final note = noteController.text.trim();
                        if (amount != null && amount > 0) {
                          context.read<DepositWithdrawCubit>().submitRequest(
                                type,
                                amount,
                                note.isEmpty ? null : note,
                                userId,
                              );
                        }
                      }
                    : null,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isDeposit ? 'Submit Deposit Request' : 'Submit Withdraw Request'),
              ),
            ],
          ),
        );
      },
    );
  }
} 