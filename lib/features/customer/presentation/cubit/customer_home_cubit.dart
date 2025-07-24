import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

part 'customer_home_state.dart';

class CustomerHomeCubit extends Cubit<CustomerHomeState> {
  final FirebaseFirestore firestore;
  final AuthCubit authCubit;

  CustomerHomeCubit({required this.firestore, required this.authCubit})
      : super(CustomerHomeState(balance: 0.0, showBalance: true, loading: true)) {
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    emit(state.copyWith(loading: true));
    final authState = authCubit.state;
    if (authState is AuthAuthenticated) {
      final uid = authState.user.id;
      final doc = await firestore.collection('users').doc(uid).get();
      final balance = (doc.data()?['balance'] ?? 0.0) as num;
      emit(state.copyWith(balance: balance.toDouble(), loading: false));
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  void toggleBalanceVisibility() {
    emit(state.copyWith(showBalance: !state.showBalance));
  }
} 