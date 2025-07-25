import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/send_money_cubit.dart';
import 'qr_scanner_page.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({Key? key}) : super(key: key);

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SendMoneyCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Send Money')),
        body: BlocConsumer<SendMoneyCubit, SendMoneyState>(
          listener: (context, state) {
            if (state is SendMoneySuccess) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Money sent successfully!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            final authState = context.read<AuthCubit>().state;
            String? senderId;
            if (authState is AuthAuthenticated) {
              senderId = authState.user.id;
            }
            if (state is SendMoneyLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                      onPressed: () async {
                        final scanned = await Navigator.of(context).push<String>(
                          MaterialPageRoute(builder: (_) => const QRScannerPage()),
                        );
                        if (scanned != null && scanned.isNotEmpty) {
                          setState(() {
                            _recipientController.text = scanned;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(labelText: 'Recipient (phone/email/ID)'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter recipient' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter amount';
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) return 'Enter valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && senderId != null) {
                          final recipient = _recipientController.text.trim();
                          final amount = double.parse(_amountController.text.trim());
                          context.read<SendMoneyCubit>().sendMoney(senderId!, recipient, amount);
                        }
                      },
                      child: const Text('Send'),
                    ),
                    if (state is SendMoneyError)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(state.message, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 