import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Equipo')),
      body: Center(
        child: Text(
          'HomeScreen — próximamente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO Dev 2: conectar a currentTeamProvider cuando TeamRepository esté listo
    );
  }
}
