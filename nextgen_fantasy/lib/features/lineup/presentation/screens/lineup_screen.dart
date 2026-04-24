import 'package:flutter/material.dart';

class LineupScreen extends StatelessWidget {
  const LineupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alineación')),
      body: Center(
        child: Text(
          'LineupScreen — próximamente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO Dev 2: conectar a currentTeamProvider cuando TeamRepository esté listo
    );
  }
}
