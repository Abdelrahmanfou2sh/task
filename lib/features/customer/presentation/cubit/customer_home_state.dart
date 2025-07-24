part of 'customer_home_cubit.dart';

class CustomerHomeState {
  final double balance;
  final bool showBalance;
  final bool loading;

  CustomerHomeState({required this.balance, required this.showBalance, this.loading = false});

  CustomerHomeState copyWith({double? balance, bool? showBalance, bool? loading}) {
    return CustomerHomeState(
      balance: balance ?? this.balance,
      showBalance: showBalance ?? this.showBalance,
      loading: loading ?? this.loading,
    );
  }
} 