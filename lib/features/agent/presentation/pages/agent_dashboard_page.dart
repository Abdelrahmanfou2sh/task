import 'package:flutter/material.dart';

class AgentDashboardPage extends StatelessWidget {
  const AgentDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Dashboard')),
      body: const Center(child: Text('Agent Dashboard')),
    );
  }
} 