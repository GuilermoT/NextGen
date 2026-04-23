import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finanzas')),
      body: Center(
        child: Text(
          'FinanceScreen — próximamente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO Dev 2: conectar a currentTeamProvider cuando TeamRepository esté listo
    );
  }
}
