import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import 'edit_personal_data_screen.dart';
import 'history_screen.dart';
import 'integrations_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) return oldValue;

    var formatted = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    String? currentCpf,
  ) async {
    final cpfController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isChecking = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final theme = Theme.of(context);
            final isLight = theme.brightness == Brightness.light;
            final textColor = isLight ? Colors.black : Colors.white;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: theme.cardColor,
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF2D55),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Excluir Conta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Para confirmar a exclusão, informe o seu CPF cadastrado:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isLight
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cpfController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CPF',
                        hintText: '000.000.000-00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final clean =
                            value?.replaceAll(RegExp(r'\D'), '') ?? '';
                        if (clean.length != 11) {
                          return 'Informe um CPF válido com 11 dígitos';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isChecking ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isChecking
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setStateDialog(() => isChecking = true);

                          try {
                            final user = supabase.auth.currentUser;
                            if (user == null) return;

                            final cleanInputCpf = cpfController.text.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            final cleanUserCpf = currentCpf?.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );

                            if (cleanUserCpf == null ||
                                cleanUserCpf.isEmpty ||
                                cleanUserCpf != cleanInputCpf) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'CPF incorreto ou não cadastrado. Verifique os dados.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              setStateDialog(() => isChecking = false);
                              return;
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                              _showFinalConfirmationDialog(context);
                            }
                          } catch (e) {
                            setStateDialog(() => isChecking = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao validar CPF: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Validar CPF',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFinalConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final isLight = theme.brightness == Brightness.light;
        final textColor = isLight ? Colors.black : Colors.white;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.cardColor,
          title: Text(
            'Tem certeza?',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Text(
            'Sua conta será desativada. Seus dados serão mantidos e você poderá reativá-la ao fazer login novamente no futuro.',
            style: TextStyle(
              fontSize: 14,
              color: isLight ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Não, cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    await supabase
                        .from('profiles')
                        .update({'is_active': false})
                        .eq('id', user.id);
                  }

                  await supabase.auth.signOut();

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao desativar conta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Sim, desativar conta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
                          Icons.link,
                          color: Color(0xFFFF2D55),
                        ),
                        title: Text(
                          'Integrações',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Strava, Garmin, Apple Health e outros',
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
                              builder: (context) => const IntegrationsScreen(),
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
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteAccountDialog(
                      context,
                      profile?['cpf']?.toString(),
                    ),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Color(0xFFFF2D55),
                    ),
                    label: const Text(
                      'Excluir Minha Conta',
                      style: TextStyle(
                        color: Color(0xFFFF2D55),
                        fontWeight: FontWeight.bold,
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
