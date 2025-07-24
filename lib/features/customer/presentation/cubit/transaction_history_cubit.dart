import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

part 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final FirebaseFirestore firestore;
  final AuthCubit authCubit;

  TransactionHistoryCubit({required this.firestore, required this.authCubit}) : super(TransactionHistoryLoading()) {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    emit(TransactionHistoryLoading());
    try {
      final authState = authCubit.state;
      if (authState is! AuthAuthenticated) {
        emit(TransactionHistoryError('Not authenticated'));
        return;
      }
      final uid = authState.user.id;
      final txSnap = await firestore.collection('users').doc(uid).collection('transactions').orderBy('timestamp', descending: true).get();
      final txs = txSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      emit(TransactionHistoryLoaded(txs));
    } catch (e) {
      emit(TransactionHistoryError('Failed to fetch transactions: $e'));
    }
  }
} 