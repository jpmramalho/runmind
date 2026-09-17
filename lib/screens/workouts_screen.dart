import 'package:flutter/material.dart';

import '../main.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _workouts = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('workouts')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: true);

        if (mounted) {
          setState(() {
            _workouts = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar treinos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleWorkoutCompletion(Map<String, dynamic> workout) async {
    final bool currentStatus = workout['is_completed'] ?? false;
    final bool newStatus = !currentStatus;

    setState(() {
      workout['is_completed'] = newStatus;
    });

    try {
      await supabase
          .from('workouts')
          .update({'is_completed': newStatus})
          .eq('id', workout['id']);

      // Verifica se todos os treinos da semana foram concluídos
      final allCompleted =
          _workouts.isNotEmpty &&
          _workouts.every((w) => w['is_completed'] == true);

      if (allCompleted && newStatus && mounted) {
        _showWeekCompletedDialog();
      }
    } catch (e) {
      setState(() {
        workout['is_completed'] = currentStatus;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar treino: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWeekCompletedDialog() {
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
          title: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                'Parabéns!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Você concluiu todos os treinos da semana! 🎉\n\nSeu novo treino para a próxima semana será gerado automaticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: isLight ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          'Treinos Semanais',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _fetchWorkouts,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWorkouts,
          color: const Color(0xFFFF2D55),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
                )
              : _workouts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum treino gerado ainda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vá em Perfil → Editar Nível e Objetivos\npara criar seu plano semanal.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final workout = _workouts[index];
                    final isCompleted = workout['is_completed'] ?? false;

                    return Card(
                      color: cardBgColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCompleted
                                ? Colors.green.withOpacity(0.2)
                                : const Color(0xFFFF2D55).withOpacity(0.15),
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.directions_run,
                              color: isCompleted
                                  ? Colors.green
                                  : const Color(0xFFFF2D55),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  workout['title'] ?? 'Treino',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2D55)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  workout['day'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFFFF2D55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isCompleted
                                        ? Colors.grey
                                        : textColor.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${workout['duration_min'] ?? 0} min',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Checkbox(
                            activeColor: const Color(0xFFFF2D55),
                            value: isCompleted,
                            onChanged: (value) =>
                                _toggleWorkoutCompletion(workout),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
