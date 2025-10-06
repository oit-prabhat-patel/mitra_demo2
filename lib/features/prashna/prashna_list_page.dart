import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrashnaListPage extends StatelessWidget {
  const PrashnaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(8, (i) => 'PRASHNA-${1000 + i}');
    return Scaffold(
      appBar: AppBar(title: const Text('Prashna Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final id = orders[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text('Order $id'),
              subtitle: const Text('Tap to record and submit audio'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/prashna/$id'),
            ),
          );
        },
      ),
    );
  }
}
