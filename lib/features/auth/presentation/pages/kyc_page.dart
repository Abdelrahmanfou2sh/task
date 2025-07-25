import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/kyc_cubit.dart';
import 'dart:io';

class KYCPage extends StatefulWidget {
  const KYCPage({Key? key}) : super(key: key);

  @override
  State<KYCPage> createState() => _KYCPageState();
}

class _KYCPageState extends State<KYCPage> {
  File? _idImage;
  File? _selfieImage;

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

  void _submitKyc(BuildContext context, String uid) {
    if (_idImage != null && _selfieImage != null) {
      context.read<KycCubit>().submitKyc(_idImage!, _selfieImage!, uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<KycCubit>(),
      child: BlocConsumer<KycCubit, KycState>(
        listener: (context, state) {
          if (state is KycSuccess) {
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
          } else if (state is KycError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit KYC: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final authState = context.read<AuthCubit>().state;
          String? uid;
          if (authState is AuthAuthenticated) {
            uid = authState.user.id;
          }
          final loading = state is KycLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('KYC Verification')),
            body: loading
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
                          onPressed: (uid != null && _idImage != null && _selfieImage != null && !loading)
                              ? () => _submitKyc(context, uid!)
                              : null,
                          child: const Text('Submit KYC'),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
} 