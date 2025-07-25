import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerHomeRepository {
  final FirebaseFirestore firestore;
  CustomerHomeRepository({required this.firestore});

  Future<double> getBalance(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return (doc.data()?['balance'] ?? 0.0) as double;
  }
} 