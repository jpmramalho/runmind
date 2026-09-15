import 'package:flutter/material.dart';

import '../main.dart';
import 'manage_subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Português';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionHeader('Assinatura'),
                _buildListTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Gerenciar assinatura',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageSubscriptionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Aparência e Preferências'),
                // Opção de alternar Tema Escuro / Claro
                SwitchListTile(
                  secondary: Icon(
                    isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: textColor,
                    size: 22,
                  ),
                  title: Text(
                    'Modo Escuro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  activeColor: const Color(0xFFFF2D55),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    setState(() {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    });
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: isLight ? Colors.grey.shade300 : Colors.grey.shade900,
                ),
                _buildListTile(
                  icon: Icons.translate_outlined,
                  title: 'Idioma',
                  subtitle: _selectedLanguage,
                  onTap: () {
                    _showLanguageSelector(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Sobre o aplicativo'),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'Termos de serviço',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'Versão',
                  subtitle: '2.22.0',
                  showArrow: false,
                ),
                _buildListTile(
                  icon: Icons.delete_outline,
                  title: 'Excluir Conta',
                  titleColor: const Color(0xFFFF2D55),
                  iconColor: const Color(0xFFFF2D55),
                  showArrow: false,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF2D55), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Color(0xFFFF2D55),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showArrow = true,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultTextColor = isLight ? Colors.black : Colors.white;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: iconColor ?? defaultTextColor, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: titleColor ?? defaultTextColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                )
              : null,
          trailing: showArrow
              ? Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20)
              : null,
          onTap: onTap,
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          indent: 16,
          endIndent: 16,
          color: isLight ? Colors.grey.shade300 : Colors.grey.shade900,
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final textColor = isLight ? Colors.black : Colors.white;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Português', style: TextStyle(color: textColor)),
                onTap: () {
                  setState(() => _selectedLanguage = 'Português');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('English', style: TextStyle(color: textColor)),
                onTap: () {
                  setState(() => _selectedLanguage = 'English');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Español', style: TextStyle(color: textColor)),
                onTap: () {
                  setState(() => _selectedLanguage = 'Español');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Excluir Conta',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação é irreversível.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Color(0xFFFF2D55)),
            ),
          ),
        ],
      ),
    );
  }
}
