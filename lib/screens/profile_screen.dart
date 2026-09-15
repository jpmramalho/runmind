import 'package:flutter/material.dart';

import '../main.dart';
import 'edit_personal_data_screen.dart';
import 'history_screen.dart';
import 'onboarding_screen.dart';

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

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final cardBgColor = isLight ? Colors.white : const Color(0xFF1C1C22);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: textColor,
            ),
            onPressed: () {
              themeNotifier.value = isLight ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
            );
          }

          final profile = snapshot.data;
          final name = profile?['name'] ?? 'Corredor';
          final level = profile?['level'] ?? 'Iniciante';
          final goal = profile?['goal'] ?? 'Não definido';
          final cpf = profile?['cpf'] ?? 'Não informado';
          final age = profile?['age'] != null
              ? '${profile!['age']} anos'
              : 'Não informada';
          final gender = profile?['gender'] ?? 'Não informado';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFFF2D55),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$level • Meta: $goal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.tune, color: Color(0xFFFF2D55)),
                    title: Text(
                      'Editar Nível e Objetivos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: const Text(
                      'Refazer teste inicial e alterar metas',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade500,
                    ),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OnboardingScreen(isEditing: true),
                        ),
                      );
                      if (updated == true) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFFF2D55),
                        ),
                        title: Text(
                          'Dados Pessoais',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'CPF: $cpf • Idade: $age • Sexo: $gender',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                        ),
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditPersonalDataScreen(),
                            ),
                          );
                          if (updated == true) {
                            setState(() {});
                          }
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade800),

                      // --- NOVO BOTÃO DE HISTÓRICO ---
                      ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: Color(0xFFFF2D55),
                        ),
                        title: Text(
                          'Histórico',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Treinos e registros de lesões',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade800),

                      ListTile(
                        leading: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFFFF2D55),
                        ),
                        title: Text(
                          'Notificações de Lembrete',
                          style: TextStyle(color: textColor),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                        ),
                        onTap: () {},
                      ),
                      Divider(height: 1, color: Colors.grey.shade800),
                      ListTile(
                        leading: const Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(0xFFFF2D55),
                        ),
                        title: Text(
                          'Privacidade e Termos',
                          style: TextStyle(color: textColor),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Sair da Conta',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
