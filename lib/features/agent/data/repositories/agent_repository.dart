import 'package:cloud_firestore/cloud_firestore.dart';

class AgentRepository {
  final FirebaseFirestore firestore;
  AgentRepository({required this.firestore});

  Future<Map<String, dynamic>> getAgentData(String uid) async {
    final agentDoc = await firestore.collection('users').doc(uid).get();
    final balance = (agentDoc.data()?['balance'] ?? 0.0) as num;
    final requestsSnap = await firestore.collection('requests')
        .where('status', isEqualTo: 'pending')
        .get();
    final requests = requestsSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
    return {
      'balance': balance.toDouble(),
      'requests': requests,
    };
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await firestore.collection('requests').doc(requestId).update({'status': status});
  }
} 