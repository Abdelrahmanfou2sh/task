part of 'kyc_cubit.dart';

abstract class KycState {}

class KycInitial extends KycState {}
class KycLoading extends KycState {}
class KycSuccess extends KycState {}
class KycError extends KycState {
  final String message;
  KycError(this.message);
} 