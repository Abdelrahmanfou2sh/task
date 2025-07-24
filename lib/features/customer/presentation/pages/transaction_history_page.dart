import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/transaction_history_cubit.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export as CSV'),
                        onPressed: () => exportToCsv(state.transactions),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export as PDF'),
                        onPressed: () => exportToPdf(state.transactions),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
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
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

Future<void> exportToCsv(List<Map<String, dynamic>> transactions) async {
  final rows = <List<String>>[
    ['Type', 'Amount', 'Date', 'Counterparty'],
    ...transactions.map((tx) => [
      tx['type'] ?? '',
      tx['amount'].toString(),
      (tx['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
      tx['type'] == 'send' ? (tx['to'] ?? '') : (tx['from'] ?? ''),
    ]),
  ];
  final csvData = const ListToCsvConverter().convert(rows);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/transactions.csv');
  await file.writeAsString(csvData);
  await Share.shareFiles([file.path], text: 'My Transaction History (CSV)');
}

Future<void> exportToPdf(List<Map<String, dynamic>> transactions) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        children: [
          pw.Text('Transaction History', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Type', 'Amount', 'Date', 'Counterparty'],
            data: transactions.map((tx) => [
              tx['type'] ?? '',
              tx['amount'].toString(),
              (tx['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
              tx['type'] == 'send' ? (tx['to'] ?? '') : (tx['from'] ?? ''),
            ]).toList(),
          ),
        ],
      ),
    ),
  );
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/transactions.pdf');
  await file.writeAsBytes(await pdf.save());
  await Share.shareFiles([file.path], text: 'My Transaction History (PDF)');
} 