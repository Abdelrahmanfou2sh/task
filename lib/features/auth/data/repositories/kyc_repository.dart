import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KycRepository {
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;

  KycRepository({required this.storage, required this.firestore});

  Future<void> uploadKyc({
    required String uid,
    required File idFile,
    required File selfieFile,
  }) async {
    final idRef = storage.ref('kyc/$uid/id.jpg');
    final selfieRef = storage.ref('kyc/$uid/selfie.jpg');
    final idUrl = await (await idRef.putFile(idFile)).ref.getDownloadURL();
    final selfieUrl = await (await selfieRef.putFile(selfieFile)).ref.getDownloadURL();
    await firestore.collection('users').doc(uid).update({
      'kyc': {
        'idUrl': idUrl,
        'selfieUrl': selfieUrl,
        'status': 'pending',
        'submittedAt': DateTime.now(),
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchPendingKycUsers() async {
    final query = await firestore.collection('users').where('kyc.status', isEqualTo: 'pending').get();
    return query.docs.map((doc) => doc.data()!..['id'] = doc.id).toList();
  }

  Future<void> approveKyc(String uid) async {
    await firestore.collection('users').doc(uid).update({
      'kyc.status': 'approved',
    });
  }

  Future<void> rejectKyc(String uid) async {
    await firestore.collection('users').doc(uid).update({
      'kyc.status': 'rejected',
    });
  }
} 