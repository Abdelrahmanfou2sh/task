import 'package:cloud_firestore/cloud_firestore.dart';

class DepositWithdrawRepository {
  final FirebaseFirestore firestore;
  DepositWithdrawRepository({required this.firestore});

  Future<void> submitRequest({
    required String userId,
    required String type,
    required double amount,
    String? note,
  }) async {
    await firestore.collection('requests').add({
      'type': type,
      'userId': userId,
      'amount': amount,
      'note': note,
      'status': 'pending',
      'timestamp': DateTime.now(),
    });
  }
} 