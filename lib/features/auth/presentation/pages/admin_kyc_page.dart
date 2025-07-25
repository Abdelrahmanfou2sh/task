import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/kyc_repository.dart';

class AdminKycPage extends StatefulWidget {
  const AdminKycPage({Key? key}) : super(key: key);

  @override
  State<AdminKycPage> createState() => _AdminKycPageState();
}

class _AdminKycPageState extends State<AdminKycPage> {
  late final KycRepository _repo;
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<KycRepository>();
    _fetchPending();
  }

  Future<void> _fetchPending() async {
    setState(() => _loading = true);
    final users = await _repo.fetchPendingKycUsers();
    setState(() {
      _pendingUsers = users;
      _loading = false;
    });
  }

  Future<void> _approve(String uid) async {
    await _repo.approveKyc(uid);
    _fetchPending();
  }

  Future<void> _reject(String uid) async {
    await _repo.rejectKyc(uid);
    _fetchPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin KYC Approval')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? const Center(child: Text('No pending KYC submissions.'))
              : ListView.builder(
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, idx) {
                    final user = _pendingUsers[idx];
                    final kyc = user['kyc'] ?? {};
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${user['id']}'),
                            if (user['email'] != null) Text('Email: ${user['email']}'),
                            const SizedBox(height: 8),
                            if (kyc['idUrl'] != null)
                              Image.network(kyc['idUrl'], height: 120, fit: BoxFit.cover),
                            const SizedBox(height: 8),
                            if (kyc['selfieUrl'] != null)
                              Image.network(kyc['selfieUrl'], height: 120, fit: BoxFit.cover),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _approve(user['id']),
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () => _reject(user['id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                              ],
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