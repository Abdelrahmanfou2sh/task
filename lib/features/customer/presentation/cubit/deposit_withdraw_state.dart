part of 'deposit_withdraw_cubit.dart';

abstract class DepositWithdrawState {}

class DepositWithdrawInitial extends DepositWithdrawState {}
class DepositWithdrawLoading extends DepositWithdrawState {}
class DepositWithdrawSuccess extends DepositWithdrawState {}
class DepositWithdrawError extends DepositWithdrawState {
  final String message;
  DepositWithdrawError(this.message);
} 