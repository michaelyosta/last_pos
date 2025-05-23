import 'package:flutter/material.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер Панель'),
      ),
      body: const Center(
        child: Text('Менеджер Панель (Placeholder)'),
      ),
    );
  }
}
