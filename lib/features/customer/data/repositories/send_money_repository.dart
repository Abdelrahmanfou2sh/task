import 'package:cloud_firestore/cloud_firestore.dart';

class SendMoneyRepository {
  final FirebaseFirestore firestore;
  SendMoneyRepository({required this.firestore});

  Future<void> sendMoney({
    required String senderId,
    required String recipient,
    required double amount,
  }) async {
    final senderDoc = firestore.collection('users').doc(senderId);
    final senderSnap = await senderDoc.get();
    final senderData = senderSnap.data();
    if (senderData == null) throw Exception('Sender not found');
    final senderBalance = (senderData['balance'] ?? 0.0) as num;
    if (senderBalance < amount) throw Exception('Insufficient funds');
    // Find recipient by email, phone, or ID
    QuerySnapshot<Map<String, dynamic>> recipientQuery;
    if (recipient.contains('@')) {
      recipientQuery = await firestore.collection('users').where('email', isEqualTo: recipient).get();
    } else if (recipient.length == 28) {
      recipientQuery = await firestore.collection('users').where(FieldPath.documentId, isEqualTo: recipient).get();
    } else {
      recipientQuery = await firestore.collection('users').where('phone', isEqualTo: recipient).get();
    }
    if (recipientQuery.docs.isEmpty) throw Exception('Recipient not found');
    final recipientDoc = recipientQuery.docs.first.reference;
    final recipientId = recipientDoc.id;
    // Transaction batch
    final batch = firestore.batch();
    batch.update(senderDoc, {'balance': senderBalance - amount});
    final recipientBalance = (recipientQuery.docs.first.data()['balance'] ?? 0.0) as num;
    batch.update(recipientDoc, {'balance': recipientBalance + amount});
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
  }
} 