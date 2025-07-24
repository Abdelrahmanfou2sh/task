import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

part 'send_money_state.dart';

class SendMoneyCubit extends Cubit<SendMoneyState> {
  final FirebaseFirestore firestore;
  final AuthCubit authCubit;

  SendMoneyCubit({required this.firestore, required this.authCubit}) : super(SendMoneyInitial());

  Future<void> sendMoney(String recipient, double amount) async {
    emit(SendMoneyLoading());
    try {
      final authState = authCubit.state;
      if (authState is! AuthAuthenticated) {
        emit(SendMoneyError('Not authenticated'));
        return;
      }
      final senderId = authState.user.id;
      final senderDoc = firestore.collection('users').doc(senderId);
      final senderSnap = await senderDoc.get();
      final senderData = senderSnap.data();
      if (senderData == null) {
        emit(SendMoneyError('Sender not found'));
        return;
      }
      final senderBalance = (senderData['balance'] ?? 0.0) as num;
      if (senderBalance < amount) {
        emit(SendMoneyError('Insufficient funds'));
        return;
      }
      // Find recipient by email, phone, or ID
      QuerySnapshot<Map<String, dynamic>> recipientQuery;
      if (recipient.contains('@')) {
        recipientQuery = await firestore.collection('users').where('email', isEqualTo: recipient).get();
      } else if (recipient.length == 28) { // Firebase UID length
        recipientQuery = await firestore.collection('users').where(FieldPath.documentId, isEqualTo: recipient).get();
      } else {
        recipientQuery = await firestore.collection('users').where('phone', isEqualTo: recipient).get();
      }
      if (recipientQuery.docs.isEmpty) {
        emit(SendMoneyError('Recipient not found'));
        return;
      }
      final recipientDoc = recipientQuery.docs.first.reference;
      final recipientId = recipientDoc.id;
      // Transaction batch
      final batch = firestore.batch();
      // Subtract from sender
      batch.update(senderDoc, {'balance': senderBalance - amount});
      // Add to recipient
      final recipientBalance = (recipientQuery.docs.first.data()['balance'] ?? 0.0) as num;
      batch.update(recipientDoc, {'balance': recipientBalance + amount});
      // Add transaction records
      final senderTx = senderDoc.collection('transactions').doc();
      final recipientTx = recipientDoc.collection('transactions').doc();
      final now = DateTime.now();
      batch.set(senderTx, {
        'type': 'send',
        'to': recipientId,
        'amount': amount,
        'timestamp': now,
      });
      batch.set(recipientTx, {
        'type': 'receive',
        'from': senderId,
        'amount': amount,
        'timestamp': now,
      });
      await batch.commit();
      emit(SendMoneySuccess());
    } catch (e) {
      emit(SendMoneyError('Failed to send money: $e'));
    }
  }
} 