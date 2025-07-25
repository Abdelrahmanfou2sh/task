import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/send_money_repository.dart';

part 'send_money_state.dart';

class SendMoneyCubit extends Cubit<SendMoneyState> {
  final SendMoneyRepository repository;
  SendMoneyCubit(this.repository) : super(SendMoneyInitial());

  Future<void> sendMoney(String senderId, String recipient, double amount) async {
    emit(SendMoneyLoading());
    try {
      await repository.sendMoney(senderId: senderId, recipient: recipient, amount: amount);
      emit(SendMoneySuccess());
    } catch (e) {
      emit(SendMoneyError(e.toString()));
    }
  }
} 