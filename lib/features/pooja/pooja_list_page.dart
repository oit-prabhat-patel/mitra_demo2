import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PoojaListPage extends StatelessWidget {
  const PoojaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(8, (i) => 'POOJA-${2000 + i}');
    return Scaffold(
      appBar: AppBar(title: const Text('Pooja Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final id = orders[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text('Order $id'),
              subtitle: const Text('Tap to record/pick video and submit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/pooja/$id'),
            ),
          );
        },
      ),
    );
  }
}
