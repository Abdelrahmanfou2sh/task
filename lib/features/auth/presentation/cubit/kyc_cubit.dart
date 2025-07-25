import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/kyc_repository.dart';

part 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  final KycRepository repository;
  KycCubit(this.repository) : super(KycInitial());

  Future<void> submitKyc(File idFile, File selfieFile, String uid) async {
    emit(KycLoading());
    try {
      await repository.uploadKyc(uid: uid, idFile: idFile, selfieFile: selfieFile);
      emit(KycSuccess());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }
} 