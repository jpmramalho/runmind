import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen.dart';

class ReactivateAccountScreen extends StatefulWidget {
  final String email;

  const ReactivateAccountScreen({Key? key, required this.email})
    : super(key: key);

  @override
  State<ReactivateAccountScreen> createState() =>
      _ReactivateAccountScreenState();
}

class _ReactivateAccountScreenState extends State<ReactivateAccountScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyAndReactivate() async {
    final token = _codeController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o código enviado ao seu e-mail.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Valida o código/token OTP enviado ao e-mail do usuário
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: widget.email,
      );

      final user = res.user;
      if (user != null) {
        // 2. Reativa o perfil atualizando 'is_active' para true
        await supabase
            .from('profiles')
            .update({
              'is_active': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta reativada com sucesso! Bem-vindo de volta.'),
              backgroundColor: Colors.green,
            ),
          );

          // 3. Entra na tela principal
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código inválido ou expirado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reativar Conta'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Color(0xFFFF2D55),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sua conta está desativada',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um código de confirmação por e-mail para:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 4),
                decoration: InputDecoration(
                  labelText: 'Código de Confirmação',
                  hintText: '123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyAndReactivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmar e Reativar Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
