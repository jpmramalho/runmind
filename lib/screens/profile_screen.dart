import 'package:flutter/material.dart';

import '../main.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
            );
          }

          final profileData = snapshot.data;
          final userName = profileData?['name'] ?? 'Usuário';
          final userEmail = currentUser?.email ?? 'Sem e-mail';
          final avatarUrl = profileData?['avatar_url'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1C1C22),
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentName: userName,
                          currentAvatarUrl: avatarUrl,
                        ),
                      ),
                    );

                    if (updated == true) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text(
                    'Editar Perfil',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Corridas', '0'),
                      _buildStatItem('Distância', '0 km'),
                      _buildStatItem('Tempo', '0h'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
