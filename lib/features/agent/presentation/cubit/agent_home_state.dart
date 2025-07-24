part of 'agent_home_cubit.dart';

abstract class AgentHomeState {}

class AgentHomeLoading extends AgentHomeState {}
class AgentHomeLoaded extends AgentHomeState {
  final double balance;
  final List<Map<String, dynamic>> requests;
  AgentHomeLoaded({required this.balance, required this.requests});
}
class AgentHomeError extends AgentHomeState {
  final String message;
  AgentHomeError(this.message);
} 