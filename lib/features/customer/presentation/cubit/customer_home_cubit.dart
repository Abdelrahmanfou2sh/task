import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customer_home_repository.dart';

part 'customer_home_state.dart';

class CustomerHomeCubit extends Cubit<CustomerHomeState> {
  final CustomerHomeRepository repository;
  CustomerHomeCubit(this.repository) : super(CustomerHomeState(balance: 0.0, showBalance: true, loading: true));

  Future<void> fetchBalance(String uid) async {
    emit(state.copyWith(loading: true));
    try {
      final balance = await repository.getBalance(uid);
      emit(state.copyWith(balance: balance, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  void toggleBalanceVisibility() {
    emit(state.copyWith(showBalance: !state.showBalance));
  }
} 