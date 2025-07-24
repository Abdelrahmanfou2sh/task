part of 'send_money_cubit.dart';

abstract class SendMoneyState {}

class SendMoneyInitial extends SendMoneyState {}
class SendMoneyLoading extends SendMoneyState {}
class SendMoneySuccess extends SendMoneyState {}
class SendMoneyError extends SendMoneyState {
  final String message;
  SendMoneyError(this.message);
} 