import 'package:flutter/material.dart';

import '../main.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  String _selectedPeriod = 'Mensal'; // Filtro: Semanal, Mensal, Anual

  final List<String> _weekDays = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
  ];
  final List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  // Verifica se o dia possui treino (Segunda, Quarta e Sábado)
  bool _hasWorkoutOnDay(DateTime date) {
    return date.weekday == DateTime.monday ||
        date.weekday == DateTime.wednesday ||
        date.weekday == DateTime.saturday;
  }

  // Verifica se o dia possui troféu de campeonato (Exemplo: dia 25)
  bool _hasTrophyOnDay(DateTime date) {
    return date.day == 25;
  }

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

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
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
          'Evolução',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER PERFIL E CONQUISTAS ---
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserProfile(),
              builder: (context, snapshot) {
                String name = 'Corredor';
                if (snapshot.hasData && snapshot.data != null) {
                  name = snapshot.data!['name'] ?? 'Corredor';
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFFF2D55),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nível Intermediário • Meta 10k',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFFF2D55),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '12 dias',
                            style: TextStyle(
                              color: Color(0xFFFF2D55),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // --- FILTRO DE PERÍODO (SEMANAL / MENSAL / ANUAL) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Semanal', 'Mensal', 'Anual'].map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF2D55) : cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- AGENDA / CALENDÁRIO COM SÍMBOLOS AJUSTADOS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: textColor),
                            onPressed: _previousMonth,
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: textColor),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekDays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendarGrid(textColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CARDS DE MÉTRICAS GERAIS E TAXA DE ADERÊNCIA ---
            Text(
              'Resumo de Desempenho',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Distância Total',
                    value: '124,5 km',
                    subtitle: '+12% este mês',
                    icon: Icons.map_outlined,
                    theme: theme,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Treinos Concluídos',
                    value: '18 / 20',
                    subtitle: '90% de taxa',
                    icon: Icons.check_circle_outline,
                    theme: theme,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Tempo de Corrida',
                    value: '12h 40m',
                    subtitle: 'Média de 42m/treino',
                    icon: Icons.timer_outlined,
                    theme: theme,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pace Médio',
                    value: '6:12 /km',
                    subtitle: 'Melhor: 5:45 /km',
                    icon: Icons.speed,
                    theme: theme,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- ANÁLISE DE PERCEPÇÃO E HUMOR NOS TREINOS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Percepção de Esforço & Sentimento',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMoodIndicator(
                        '😄',
                        'Excelente',
                        '65%',
                        Colors.green,
                      ),
                      _buildMoodIndicator('🙂', 'Bom', '25%', Colors.blue),
                      _buildMoodIndicator('😐', 'Normal', '10%', Colors.orange),
                      _buildMoodIndicator('😫', 'Cansado', '0%', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- HISTÓRICO DE TREINOS RECENTES ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico Recente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver Todos',
                    style: TextStyle(color: Color(0xFFFF2D55)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildWorkoutHistoryItem(
              title: 'Rodagem Contínua',
              date: 'Sábado, 20 de Setembro',
              distance: '4.53 km',
              pace: '6:37 /km',
              duration: '30:00',
              theme: theme,
              textColor: textColor,
            ),
            const SizedBox(height: 10),
            _buildWorkoutHistoryItem(
              title: 'Treino de TI (Intervalado)',
              date: 'Quarta, 17 de Setembro',
              distance: '7.00 km',
              pace: '5:45 /km',
              duration: '50:00',
              theme: theme,
              textColor: textColor,
            ),
            const SizedBox(height: 24),

            // --- BOTÃO EXPORTAR RELATÓRIO ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gerando relatório de evolução em PDF...'),
                      backgroundColor: Color(0xFFFF2D55),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFFFF2D55),
                ),
                label: const Text(
                  'Exportar Relatório em PDF',
                  style: TextStyle(
                    color: Color(0xFFFF2D55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF2D55)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Color textColor) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + startingWeekday,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        if (index < startingWeekday) {
          return const SizedBox();
        }

        final dayNumber = index - startingWeekday + 1;
        final date = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          dayNumber,
        );

        final isToday = DateUtils.isSameDay(date, today);
        final isSelected =
            _selectedDay != null && DateUtils.isSameDay(date, _selectedDay);
        final hasWorkout = _hasWorkoutOnDay(date);
        final hasTrophy = _hasTrophyOnDay(date);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFFFF2D55)
                  : (isSelected
                        ? const Color(0xFFFF2D55).withOpacity(0.3)
                        : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : textColor,
                  ),
                ),
                if (hasTrophy)
                  const Positioned(
                    bottom: 2,
                    child: Icon(
                      Icons.emoji_events,
                      size: 11,
                      color: Color(0xFFFFD700),
                    ),
                  )
                else if (hasWorkout)
                  Positioned(
                    bottom: 2,
                    child: Icon(
                      Icons.directions_run,
                      size: 11,
                      color: isToday ? Colors.white : const Color(0xFFFF2D55),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF2D55), size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(
    String emoji,
    String label,
    String percentage,
    Color color,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildWorkoutHistoryItem({
    required String title,
    required String date,
    required String distance,
    required String pace,
    required String duration,
    required ThemeData theme,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_run,
              color: Color(0xFFFF2D55),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '$pace • $duration',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
