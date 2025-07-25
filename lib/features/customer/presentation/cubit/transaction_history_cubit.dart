import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_history_repository.dart';

part 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final TransactionHistoryRepository repository;
  TransactionHistoryCubit(this.repository) : super(TransactionHistoryLoading());

  Future<void> fetchTransactions(String uid) async {
    emit(TransactionHistoryLoading());
    try {
      final txs = await repository.getTransactions(uid);
      emit(TransactionHistoryLoaded(txs));
    } catch (e) {
      emit(TransactionHistoryError('Failed to fetch transactions: $e'));
    }
  }
} 