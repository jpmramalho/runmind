import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

// Formatador de máscara para CPF: 000.000.000-00
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class EditPersonalDataScreen extends StatefulWidget {
  const EditPersonalDataScreen({super.key});

  @override
  State<EditPersonalDataScreen> createState() => _EditPersonalDataScreenState();
}

class _EditPersonalDataScreenState extends State<EditPersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  String _selectedGender = 'Masculino';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _ageController.text = data['age'] != null
                ? data['age'].toString()
                : '';
            _selectedGender = data['gender'] ?? 'Masculino';
            _cpfController.text = data['cpf'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePersonalData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('profiles')
            .update({
              'name': _nameController.text.trim(),
              'age': int.tryParse(_ageController.text.trim()) ?? 0,
              'gender': _selectedGender,
              'cpf': _cpfController.text.trim(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados pessoais atualizados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(
        context,
        true,
      ); // Retorna true para recarregar a tela anterior
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Dados Pessoais'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Altere suas informações básicas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nome Completo
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe seu nome' : null,
                      ),
                      const SizedBox(height: 16),

                      // Idade e Sexo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Idade',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Informe a idade'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Sexo',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Masculino', 'Feminino', 'Outro'].map((
                                g,
                              ) {
                                return DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // CPF
                      TextFormField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CpfInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          hintText: '000.000.000-00',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu CPF';
                          if (v.length < 14) return 'CPF incompleto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2D55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSaving ? null : _savePersonalData,
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Salvar Alterações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
