import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mercado')),
      body: Center(
        child: Text(
          'MarketScreen — próximamente',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO Dev 2: conectar a currentTeamProvider cuando TeamRepository esté listo
    );
  }
}
