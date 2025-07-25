import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/deposit_withdraw_repository.dart';

part 'deposit_withdraw_state.dart';

class DepositWithdrawCubit extends Cubit<DepositWithdrawState> {
  final DepositWithdrawRepository repository;
  DepositWithdrawCubit(this.repository) : super(DepositWithdrawInitial());

  Future<void> submitRequest(String type, double amount, String? note, String userId) async {
    emit(DepositWithdrawLoading());
    try {
      await repository.submitRequest(userId: userId, type: type, amount: amount, note: note);
      emit(DepositWithdrawSuccess());
    } catch (e) {
      emit(DepositWithdrawError(e.toString()));
    }
  }
} 