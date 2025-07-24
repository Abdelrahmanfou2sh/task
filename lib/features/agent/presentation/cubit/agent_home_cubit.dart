import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

part 'agent_home_state.dart';

class AgentHomeCubit extends Cubit<AgentHomeState> {
  final FirebaseFirestore firestore;
  final AuthCubit authCubit;

  AgentHomeCubit({required this.firestore, required this.authCubit}) : super(AgentHomeLoading()) {
    fetchData();
  }

  Future<void> fetchData() async {
    emit(AgentHomeLoading());
    try {
      final authState = authCubit.state;
      if (authState is! AuthAuthenticated) {
        emit(AgentHomeError('Not authenticated'));
        return;
      }
      final uid = authState.user.id;
      final agentDoc = await firestore.collection('users').doc(uid).get();
      final balance = (agentDoc.data()?['balance'] ?? 0.0) as num;
      final requestsSnap = await firestore.collection('requests')
        .where('status', isEqualTo: 'pending')
        .get();
      final requests = requestsSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      emit(AgentHomeLoaded(balance: balance.toDouble(), requests: requests));
    } catch (e) {
      emit(AgentHomeError('Failed to fetch agent data: $e'));
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await firestore.collection('requests').doc(requestId).update({'status': status});
      fetchData();
    } catch (e) {
      // Optionally emit error state
    }
  }
} 