import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen.dart'; // Importação corrigida para referenciar a MainScreen na mesma pasta

class OnboardingScreen extends StatefulWidget {
  final bool isEditing;

  const OnboardingScreen({Key? key, this.isEditing = false}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final supabase = Supabase.instance.client;

  String? _selectedLevel;
  String? _selectedGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadCurrentUserData();
    }
  }

  Future<void> _loadCurrentUserData() async {
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
  }

  Future<void> _saveGoalsAndGenerateWorkouts() async {
    if (_selectedLevel == null || _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um nível e um objetivo para continuar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profileResponse = await supabase
          .from('profiles')
          .select('age')
          .eq('id', user.id)
          .maybeSingle();

      final int userAge = profileResponse?['age'] ?? 25;

      await supabase.from('profiles').upsert({
        'id': user.id,
        'level': _selectedLevel,
        'goal': _selectedGoal,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('workouts').delete().eq('user_id', user.id);

      List<Map<String, dynamic>> items = [];

      final templateResponse = await supabase
          .from('workout_templates')
          .select('*, workout_template_items(*)')
          .eq('level', _selectedLevel!)
          .eq('goal', _selectedGoal!)
          .maybeSingle();

      if (templateResponse != null &&
          templateResponse['workout_template_items'] != null) {
        items = List<Map<String, dynamic>>.from(
          templateResponse['workout_template_items'],
        );
      } else {
        items = await _loadPlanFromLocalJson(_selectedLevel!, _selectedGoal!);
      }

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Nenhum plano encontrado para este nível e objetivo.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newWorkouts = items.map((item) {
        String customDescription =
            '${item['description'] ?? ''} (Foco: $_selectedGoal)';

        if (userAge >= 45) {
          customDescription +=
              ' - *Atenção reforçada ao aquecimento e recuperação.*';
        }

        return {
          'user_id': user.id,
          'title': item['title'] ?? 'Treino',
          'description': customDescription,
          'day': item['day'] ?? '',
          'duration_min': item['duration_min'] ?? 0,
          'is_completed': false,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await supabase.from('workouts').insert(newWorkouts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plano de treinos atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isEditing) {
          Navigator.of(context).pop(true);
        } else {
          // Redireciona para a classe MainScreen() usando navegação direta via MaterialPageRoute
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao salvar plano: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar plano: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadPlanFromLocalJson(
    String level,
    String goal,
  ) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/runmind_planos_completos.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List plans = jsonData['plans'] ?? [];

      final plan = plans.firstWhere(
        (p) => p['level'] == level && p['goal'] == goal,
        orElse: () => null,
      );

      if (plan != null && plan['workouts'] != null) {
        return List<Map<String, dynamic>>.from(plan['workouts']);
      }
    } catch (e) {
      debugPrint('Erro ao carregar JSON local: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Editar Nível e Objetivos'
              : 'Configuração Inicial',
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Qual o seu nível atual?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLevelOption(
                    'Iniciante',
                    'Pouca ou nenhuma experiência com corrida',
                    Icons.directions_walk,
                  ),
                  _buildLevelOption(
                    'Intermediário',
                    'Já corre com frequência e quer melhorar a constância',
                    Icons.directions_run,
                  ),
                  _buildLevelOption(
                    'Avançado',
                    'Atleta experiente em busca de novos tempos e metas',
                    Icons.directions_bike,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Qual é o seu objetivo principal?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildGoalOption(
                    '5km',
                    'Completar ou melhorar o tempo nos 5 km',
                    Icons.flag_outlined,
                  ),
                  _buildGoalOption(
                    '10km',
                    'Aumentar a rodagem para fechar 10 km',
                    Icons.emoji_events_outlined,
                  ),
                  _buildGoalOption(
                    'Meia Maratona',
                    'Desafio de 21 km em ritmo sustentável',
                    Icons.military_tech_outlined,
                  ),
                  _buildGoalOption(
                    'Maratona',
                    'Preparação completa para 42 km',
                    Icons.workspace_premium_outlined,
                  ),
                  const SizedBox(height: 32),
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
                      onPressed: _saveGoalsAndGenerateWorkouts,
                      child: Text(
                        widget.isEditing
                            ? 'Salvar e Recalcular Treinos'
                            : 'Gerar Plano de Treinos',
                        style: const TextStyle(
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
    );
  }

  Widget _buildLevelOption(String title, String description, IconData icon) {
    final isSelected = _selectedLevel == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF2D55);

    final cardBgColor = isSelected
        ? (isDark
              ? primaryColor.withOpacity(0.25)
              : primaryColor.withOpacity(0.12))
        : (isDark ? Colors.grey.shade900 : Colors.grey.shade100);

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300);

    final titleColor = isSelected
        ? (isDark ? Colors.white : primaryColor)
        : (isDark ? Colors.grey.shade200 : Colors.black87);

    final iconColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedLevel = title),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String description, IconData icon) {
    final isSelected = _selectedGoal == title;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF2D55);

    final cardBgColor = isSelected
        ? (isDark
              ? primaryColor.withOpacity(0.25)
              : primaryColor.withOpacity(0.12))
        : (isDark ? Colors.grey.shade900 : Colors.grey.shade100);

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300);

    final titleColor = isSelected
        ? (isDark ? Colors.white : primaryColor)
        : (isDark ? Colors.grey.shade200 : Colors.black87);

    final iconColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedGoal = title),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
