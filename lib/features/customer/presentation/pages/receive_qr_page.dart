import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

class ReceiveQRPage extends StatelessWidget {
  const ReceiveQRPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String code = '';
    if (authState is AuthAuthenticated) {
      code = authState.user.id;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Money (QR Code)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImage(
              data: code,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            Text('Your Code: $code'),
          ],
        ),
      ),
    );
  }
} 