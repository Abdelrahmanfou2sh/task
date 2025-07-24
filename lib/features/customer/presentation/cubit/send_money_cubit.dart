import 'package:flutter_bloc/flutter_bloc.dart';

part 'send_money_state.dart';

class SendMoneyCubit extends Cubit<SendMoneyState> {
  SendMoneyCubit() : super(SendMoneyInitial());

  Future<void> sendMoney(String recipient, double amount) async {
    emit(SendMoneyLoading());
    try {
      // TODO: Implement send money logic (mock for now)
      await Future.delayed(const Duration(seconds: 1));
      emit(SendMoneySuccess());
    } catch (e) {
      emit(SendMoneyError(e.toString()));
    }
  }
} 