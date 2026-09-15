import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import 'main_screen.dart';

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

class OnboardingScreen extends StatefulWidget {
  final bool isEditing;

  const OnboardingScreen({super.key, this.isEditing = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  String _selectedGender = 'Masculino';

  final List<String> _levels = [
    'Iniciante',
    'Casual',
    'Intermediário',
    'Avançado',
    'Profissional / Elite',
  ];
  String? _selectedLevel;

  final List<Map<String, String>> _goals = [
    {'title': 'Perder peso', 'desc': 'Foco em queima calórica e consistência'},
    {
      'title': 'Melhorar o condicionamento físico',
      'desc': 'Saúde geral, mais fôlego e energia',
    },
    {
      'title': 'Correr minha primeira 5K / 10K',
      'desc': 'Meta de distância específica para iniciantes',
    },
    {
      'title': 'Treinar para uma prova (21K, 42K)',
      'desc': 'Plano estruturado com data-alvo',
    },
    {
      'title': 'Melhorar meu pace / performance',
      'desc': 'Foco em velocidade e ritmo',
    },
    {
      'title': 'Criar o hábito de correr',
      'desc': 'Consistência, sem foco em performance',
    },
    {
      'title': 'Reduzir estresse / saúde mental',
      'desc': 'Bem-estar, corrida como terapia',
    },
    {
      'title': 'Voltar a correr após uma pausa',
      'desc': 'Retorno gradual, evitar lesões',
    },
  ];
  String? _selectedGoal;

  int _currentStep = 0;
  bool _isLoading = true; // Inicia true para carregar os dados existentes

  @override
  void initState() {
    super.initState();
    _loadExistingUserData();
  }

  // Busca as informações gravadas no Supabase e preenche os campos
  Future<void> _loadExistingUserData() async {
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
            _selectedLevel =
                data['level']; // Se for nulo, nada fica selecionado
            _selectedGoal = data['goal']; // Se for nulo, nada fica selecionado
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'gender': _selectedGender,
          'cpf': _cpfController.text.trim(),
          'level': _selectedLevel,
          'goal': _selectedGoal,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
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
        setState(() {
          _isLoading = false;
        });
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
        title: Text(
          widget.isEditing
              ? 'Editar Perfil e Objetivos'
              : 'Configuração Inicial',
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) _buildPersonalInfoStep(textColor),
                    if (_currentStep == 1) _buildLevelStep(textColor),
                    if (_currentStep == 2) _buildGoalStep(textColor),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => setState(() => _currentStep--),
                            child: const Text('Voltar'),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2D55),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_currentStep == 0) {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _currentStep++);
                                    }
                                  } else if (_currentStep == 1) {
                                    if (_selectedLevel != null) {
                                      setState(() => _currentStep++);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Selecione seu nível de corrida',
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (_currentStep == 2) {
                                    if (_selectedGoal != null) {
                                      _saveProfileData();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Selecione o seu objetivo principal',
                                              ),
                                            ),
                                          );
                                    }
                                  }
                                },
                          child: Text(
                            _currentStep == 2 ? 'Concluir' : 'Avançar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(Color textColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados Pessoais',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: 12),
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
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a idade' : null,
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
                  items: ['Masculino', 'Feminino', 'Outro'].map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              if (v.length < 14) return 'CPF incompleto (000.000.000-00)';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStep(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual é o seu nível atual?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._levels.map((level) {
          final isSelected = _selectedLevel == level;
          return Card(
            color: isSelected
                ? const Color(0xFFFF2D55).withOpacity(0.15)
                : null,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF2D55)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                level,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFFFF2D55))
                  : null,
              onTap: () => setState(() => _selectedLevel = level),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoalStep(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual o seu objetivo com a corrida?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._goals.map((item) {
          final isSelected = _selectedGoal == item['title'];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? const Color(0xFFFF2D55).withOpacity(0.15)
                : null,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF2D55)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                item['title']!,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              subtitle: Text(
                item['desc']!,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFFFF2D55))
                  : null,
              onTap: () => setState(() => _selectedGoal = item['title']),
            ),
          );
        }),
      ],
    );
  }
}
