import 'package:flutter/material.dart';

import '../data/workout_templates.dart';
import '../main.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEditing;

  const OnboardingScreen({super.key, this.isEditing = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingUserData();
  }

  Future<void> _loadExistingUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select('level, goal')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _selectedLevel = data['level'];
            _selectedGoal = data['goal'];
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados de metas: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSaveFlow() async {
    if (widget.isEditing) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atualizar Plano de Treinos?'),
            content: Text(
              'Você alterou suas metas para o nível "$_selectedLevel". Deseja gerar um novo plano semanal de treinos com base nessa escolha?\n\n'
              'Ao clicar em SIM, seu cronograma de treinos atual será substituído.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'NÃO (Manter atual)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'SIM (Gerar novos)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await _saveGoalsAndGenerateWorkouts(generateNewWorkouts: true);
      } else if (confirm == false) {
        await _saveGoalsAndGenerateWorkouts(generateNewWorkouts: false);
      }
    } else {
      await _saveGoalsAndGenerateWorkouts(generateNewWorkouts: true);
    }
  }

  Future<void> _saveGoalsAndGenerateWorkouts({
    required bool generateNewWorkouts,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user != null) {
        // 1. Busca idade e sexo salvos no perfil para adaptar os treinos
        final profileResponse = await supabase
            .from('profiles')
            .select('age, gender')
            .eq('id', user.id)
            .maybeSingle();

        final int userAge = profileResponse?['age'] ?? 25;

        // 2. Atualiza Nível e Objetivo no Perfil
        await supabase
            .from('profiles')
            .update({
              'level': _selectedLevel,
              'goal': _selectedGoal,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);

        // 3. Se confirmou a substituição (ou cadastro inicial), cria os novos treinos
        if (generateNewWorkouts && _selectedLevel != null) {
          await supabase.from('workouts').delete().eq('user_id', user.id);

          final selectedTemplate =
              WorkoutTemplates.templates[_selectedLevel] ?? [];
          final newWorkouts = selectedTemplate.map((item) {
            String customDescription =
                '${item['description']} (Foco: $_selectedGoal)';

            // Exemplo de adaptação fisiológica simples por idade
            if (userAge >= 45) {
              customDescription +=
                  ' - *Atenção reforçada ao aquecimento e recuperação.*';
            }

            return {
              'user_id': user.id,
              'title': item['title'],
              'description': customDescription,
              'day': item['day'],
              'duration_min': item['duration_min'],
              'is_completed': false,
              'created_at': DateTime.now().toIso8601String(),
            };
          }).toList();

          if (newWorkouts.isNotEmpty) {
            await supabase.from('workouts').insert(newWorkouts);
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

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
              ? 'Editar Nível e Objetivos'
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
                    if (_currentStep == 0) _buildLevelStep(textColor),
                    if (_currentStep == 1) _buildGoalStep(textColor),
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
                                  } else if (_currentStep == 1) {
                                    if (_selectedGoal != null) {
                                      _handleSaveFlow();
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
                            _currentStep == 1 ? 'Concluir' : 'Avançar',
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
