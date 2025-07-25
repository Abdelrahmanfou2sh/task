import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistoryRepository {
  final FirebaseFirestore firestore;
  TransactionHistoryRepository({required this.firestore});

  Future<List<Map<String, dynamic>>> getTransactions(String uid) async {
    final txSnap = await firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .get();
    return txSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }
} 