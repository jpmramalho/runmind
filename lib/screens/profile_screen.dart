import 'package:flutter/material.dart';

import 'settings_screen.dart'; // Garanta esta importação

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.white),
            title: const Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
            onTap: () {
              // AÇÃO DE NAVEGAÇÃO PARA A TELA DE AJUSTES
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
