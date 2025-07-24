import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'dart:io';

class KYCPage extends StatefulWidget {
  const KYCPage({Key? key}) : super(key: key);

  @override
  State<KYCPage> createState() => _KYCPageState();
}

class _KYCPageState extends State<KYCPage> {
  File? _idImage;
  File? _selfieImage;
  bool _loading = false;

  Future<void> _pickImage(bool isId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isId) {
          _idImage = File(picked.path);
        } else {
          _selfieImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _submitKYC() async {
    if (_idImage == null || _selfieImage == null) return;
    setState(() => _loading = true);
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    final uid = authState.user.id;
    final storage = FirebaseStorage.instance;
    final firestore = GetIt.I<FirebaseFirestore>();
    try {
      final idRef = storage.ref('kyc/$uid/id.jpg');
      final selfieRef = storage.ref('kyc/$uid/selfie.jpg');
      final idUrl = await (await idRef.putFile(_idImage!)).ref.getDownloadURL();
      final selfieUrl = await (await selfieRef.putFile(_selfieImage!)).ref.getDownloadURL();
      await firestore.collection('users').doc(uid).update({
        'kyc': {
          'idUrl': idUrl,
          'selfieUrl': selfieUrl,
          'status': 'pending',
          'submittedAt': DateTime.now(),
        }
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('KYC Submitted'),
          content: const Text('Your KYC documents have been submitted for review.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        _idImage = null;
        _selfieImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit KYC: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Step 1: Upload Photo ID'),
                  const SizedBox(height: 8),
                  _idImage != null
                      ? Image.file(_idImage!, height: 120)
                      : const Text('No ID image selected'),
                  ElevatedButton(
                    onPressed: () => _pickImage(true),
                    child: const Text('Take/Upload ID Photo'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Step 2: Upload Selfie'),
                  const SizedBox(height: 8),
                  _selfieImage != null
                      ? Image.file(_selfieImage!, height: 120)
                      : const Text('No selfie selected'),
                  ElevatedButton(
                    onPressed: () => _pickImage(false),
                    child: const Text('Take/Upload Selfie'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: (_idImage != null && _selfieImage != null && !_loading) ? _submitKYC : null,
                    child: const Text('Submit KYC'),
                  ),
                ],
              ),
            ),
    );
  }
} 