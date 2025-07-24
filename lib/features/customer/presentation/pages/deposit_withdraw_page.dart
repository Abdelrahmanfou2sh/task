import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

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

  Future<void> _submitRequest(String type) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    final userId = authState.user.id;
    final amount = type == 'deposit'
        ? double.tryParse(_depositAmountController.text.trim())
        : double.tryParse(_withdrawAmountController.text.trim());
    final note = type == 'deposit'
        ? _depositNoteController.text.trim()
        : _withdrawNoteController.text.trim();
    if (amount == null || amount <= 0) return;
    final firestore = GetIt.I<FirebaseFirestore>();
    await firestore.collection('requests').add({
      'type': type,
      'userId': userId,
      'amount': amount,
      'note': note,
      'timestamp': DateTime.now(),
    });
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
    if (type == 'deposit') {
      _depositAmountController.clear();
      _depositNoteController.clear();
    } else {
      _withdrawAmountController.clear();
      _withdrawNoteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit / Withdraw'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Deposit'),
            Tab(text: 'Withdraw'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm('deposit'),
          _buildForm('withdraw'),
        ],
      ),
    );
  }

  Widget _buildForm(String type) {
    final isDeposit = type == 'deposit';
    final amountController = isDeposit ? _depositAmountController : _withdrawAmountController;
    final noteController = isDeposit ? _depositNoteController : _withdrawNoteController;
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
            onPressed: () => _submitRequest(type),
            child: Text(isDeposit ? 'Submit Deposit Request' : 'Submit Withdraw Request'),
          ),
        ],
      ),
    );
  }
} 