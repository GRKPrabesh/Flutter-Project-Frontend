import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 12),
        const Center(child: Text('John Doe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
        const Center(child: Text('doejhn@gmail.com', style: TextStyle(color: Colors.black54))),
        const SizedBox(height: 24),
        _tile(icon: Icons.person_outline, title: 'Personal Details', onTap: () {}),
        _tile(icon: Icons.lock_outline, title: 'Password & Security', onTap: () {}),
        _tile(icon: Icons.color_lens_outlined, title: 'Theme', onTap: () {}),
        _tile(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () {},
          child: const Text('Logout'),
        )
      ],
    );
  }

  Widget _tile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(children: [
      ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
      const Divider(height: 1)
    ]);
  }
}
