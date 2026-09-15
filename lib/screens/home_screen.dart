import 'package:flutter/material.dart';

import 'workout_detail_screen.dart'; // Importação adicionada para resolver o erro

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({super.key, this.onToggleTheme, this.isDarkMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controle de Feedback e Trava de Semanas
  bool isFeedbackCompleted = false;
  int currentWeekOffset = 0;

  late DateTime selectedDate;
  late DateTime startOfCurrentWeek;

  final Map<String, Map<String, dynamic>> workoutMap = {
    '2026-09-13': {'title': 'Descanso', 'type': 'rest'},
    '2026-09-14': {
      'title': 'Corrida Leve (Z2)',
      'duration': '40:00',
      'distance': '5,00 km',
      'type': 'workout',
      'week': 'Semana 1/17',
    },
    '2026-09-15': {'title': 'Descanso', 'type': 'rest'},
    '2026-09-16': {
      'title': 'Treino de Tiros',
      'duration': '45:00',
      'distance': '6,20 km',
      'type': 'workout',
      'week': 'Semana 1/17',
    },
    '2026-09-17': {
      'title': 'Fartlek Curto',
      'duration': '31:30',
      'distance': '4,44 km',
      'type': 'workout',
      'week': 'Semana 1/17',
    },
    '2026-09-18': {'title': 'Descanso', 'type': 'rest'},
    '2026-09-19': {
      'title': 'Longo Contínuo',
      'duration': '01:06:40',
      'distance': '10,00 km',
      'type': 'workout',
      'week': 'Semana 1/17',
    },
    '2026-09-20': {'title': 'Descanso', 'type': 'rest'},
  };

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime(2026, 9, 18);
    selectedDate = now;
    startOfCurrentWeek = now.subtract(Duration(days: now.weekday % 7));
  }

  void _changeWeek(int offset) {
    if (offset > 0 && currentWeekOffset >= 0 && !isFeedbackCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Envie o feedback dos treinos da semana atual para liberar a próxima semana!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFFF2D55),
        ),
      );
      return;
    }

    setState(() {
      currentWeekOffset += offset;
      selectedDate = selectedDate.add(Duration(days: offset * 7));
    });
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getMonthYearHeader(DateTime date) {
    const months = [
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO',
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  String _getDayName(int weekday) {
    const days = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    return days[weekday % 7];
  }

  String _getFormattedFullDate(DateTime date) {
    const days = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return "${days[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    DateTime weekStart = startOfCurrentWeek.add(
      Duration(days: currentWeekOffset * 7),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Olá, Júlia',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF2D55)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CALENDÁRIO SEMANAL DE SELEÇÃO
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getMonthYearHeader(weekStart),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () => _changeWeek(-1),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.chevron_right,
                            color:
                                (currentWeekOffset >= 0 && !isFeedbackCompleted)
                                ? Colors.grey
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                          onPressed: () => _changeWeek(1),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    DateTime dayDate = weekStart.add(Duration(days: index));
                    bool isSelected =
                        dayDate.day == selectedDate.day &&
                        dayDate.month == selectedDate.month;
                    bool isToday =
                        dayDate.day == DateTime.now().day &&
                        dayDate.month == DateTime.now().month;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = dayDate;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF2D55)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getDayName(dayDate.weekday),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black45),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dayDate.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            if (isToday && !isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF2D55),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // LISTA DE DETALHES DO DIA SELECIONADO E SUBSEQUENTE
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDayWorkoutCard(selectedDate, isDark),
                const SizedBox(height: 12),
                _buildDayWorkoutCard(
                  selectedDate.add(const Duration(days: 1)),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayWorkoutCard(DateTime date, bool isDark) {
    String dateKey = _formatDateKey(date);
    Map<String, dynamic>? workout = workoutMap[dateKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
          child: Text(
            _getFormattedFullDate(date),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: (date.day == selectedDate.day)
                  ? const Color(0xFFFF2D55)
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
        if (workout == null || workout['type'] == 'rest')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Descanso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutDetailScreen(workout: workout),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF2D55),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              workout['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            workout['week'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['duration'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.flag_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['distance'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
