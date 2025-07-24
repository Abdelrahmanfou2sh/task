part of 'transaction_history_cubit.dart';

abstract class TransactionHistoryState {}

class TransactionHistoryLoading extends TransactionHistoryState {}
class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<Map<String, dynamic>> transactions;
  TransactionHistoryLoaded(this.transactions);
}
class TransactionHistoryError extends TransactionHistoryState {
  final String message;
  TransactionHistoryError(this.message);
} 