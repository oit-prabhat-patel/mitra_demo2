import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/home_cards.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          HomeTile(
            icon: Icons.record_voice_over,
            title: 'Prashna',
            subtitle: 'View orders and record audio answers',
            onTap: () => context.go('/prashna'),
          ),
          HomeTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Pooja',
            subtitle: 'View orders and record video updates',
            onTap: () => context.go('/pooja'),
          ),
        ],
      ),
    );
  }
}
