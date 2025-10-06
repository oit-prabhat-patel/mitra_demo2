import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Demo User'),
            subtitle: Text('demo@user.app'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.badge_outlined),
            title: Text('Kundali ID'),
            subtitle: Text('#PRAS-001'),
          ),
        ],
      ),
    );
  }
}
