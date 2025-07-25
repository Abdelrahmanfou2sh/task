import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/repositories/agent_repository.dart';

part 'agent_home_state.dart';

class AgentHomeCubit extends Cubit<AgentHomeState> {
  final AgentRepository repository;
  final AuthCubit authCubit;

  AgentHomeCubit({required this.repository, required this.authCubit}) : super(AgentHomeLoading()) {
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
      final data = await repository.getAgentData(uid);
      emit(AgentHomeLoaded(balance: data['balance'], requests: data['requests']));
    } catch (e) {
      emit(AgentHomeError('Failed to fetch agent data: $e'));
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await repository.updateRequestStatus(requestId, status);
      fetchData();
    } catch (e) {
      // Optionally emit error state
    }
  }
} 