import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentWeekStart;
  late DateTime _selectedDate;
  final DateTime _today = DateTime.now();

  final List<String> _weekDayNames = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
  ];
  final List<String> _monthNames = [
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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _currentWeekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday % 7),
    );
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

  void _nextWeek() {
    final nextWeekStart = _currentWeekStart.add(const Duration(days: 7));
    final currentWeekStartSunday = _today.subtract(
      Duration(days: _today.weekday % 7),
    );

    if (nextWeekStart.isAfter(currentWeekStartSunday)) {
      _showWarningSnackBar(
        'É preciso concluir o treino da semana para avançar.',
      );
    } else {
      setState(() {
        _currentWeekStart = nextWeekStart;
      });
    }
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF2D55),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, dynamic> _getWorkoutDetailsForDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return {
          'type': 'treino',
          'title': 'Treino Regenerativo',
          'subtitle': '1 mês com a IA - Semana 1/17',
          'duration': '45:00',
          'distance': '5,00 km',
          'pace': '6:30 /km',
          'paceRange': '45:00 min entre 6:15 e 6:45 min/km',
          'carga': '5 ZP',
        };
      case DateTime.wednesday:
        return {
          'type': 'treino',
          'title': 'Treino de TI (Intervalado)',
          'subtitle': '1 mês com a IA - Semana 1/17',
          'duration': '50:00',
          'distance': '7,00 km',
          'pace': '5:45 /km',
          'paceRange': '50:00 min entre 5:30 e 6:00 min/km',
          'carga': '8 ZP',
        };
      case DateTime.saturday:
        return {
          'type': 'treino',
          'title': 'Rodagem Contínua',
          'subtitle': '1 mês com a IA - Semana 1/17',
          'duration': '30:00',
          'distance': '4,53 km',
          'pace': '6:37 /km',
          'paceRange': '30:00 min entre 6:22 e 6:52 min/km',
          'carga': '6 ZP',
        };
      default:
        return {
          'type': 'descanso',
          'title': 'Descanso Muscular',
          'subtitle': '1 mês com a IA - Dia de recuperação',
          'duration': '00:00',
          'distance': '0,00 km',
          'pace': '-',
          'paceRange': 'Descanso total ou mobilidade leve.',
          'carga': '0 ZP',
        };
    }
  }

  String _formatDateTitle(DateTime date) {
    final dayNamesFull = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    final monthNamesFull = [
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

    final dayName = dayNamesFull[date.weekday % 7];
    final monthName = monthNamesFull[date.month - 1];
    return '$dayName, ${date.day} de $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;

    final weekDays = List.generate(
      7,
      (index) => _currentWeekStart.add(Duration(days: index)),
    );
    final monthYearTitle =
        '${_monthNames[_currentWeekStart.month - 1]} ${_currentWeekStart.year}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _fetchUserProfile(),
                builder: (context, snapshot) {
                  String name = '';
                  if (snapshot.hasData && snapshot.data != null) {
                    name = snapshot.data!['name'] ?? '';
                  }
                  final displayName = name.isNotEmpty ? name : 'Corredor';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Olá, $displayName',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLight
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              color: textColor,
                            ),
                            onPressed: () {
                              themeNotifier.value = isLight
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                          ),
                          Icon(Icons.notifications_outlined, color: textColor),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Calendário da semana
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthYearTitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              color: Colors.grey.shade500,
                              onPressed: _previousWeek,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              color: Colors.grey.shade500,
                              onPressed: _nextWeek,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final dayDate = weekDays[index];
                        final dayName = _weekDayNames[index];
                        final workoutInfo = _getWorkoutDetailsForDay(dayDate);
                        final hasWorkout = workoutInfo['type'] == 'treino';

                        return _buildDayItem(
                          dayName,
                          dayDate,
                          textColor,
                          hasWorkout: hasWorkout,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Lista de treinos do dia
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final dayDate = weekDays[index];
                  final workout = _getWorkoutDetailsForDay(dayDate);
                  final isRestDay = workout['type'] == 'descanso';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTitle(dayDate),
                          style: TextStyle(
                            color: isRestDay
                                ? const Color(0xFFFF2D55)
                                : textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            // Se for dia de descanso, desativa a interatividade do clique (onTap: null)
                            onTap: isRestDay
                                ? null
                                : () async {
                                    final profile = await _fetchUserProfile();
                                    final fullName = profile != null
                                        ? (profile['name'] ?? '')
                                        : '';
                                    final firstName = fullName.isNotEmpty
                                        ? fullName.split(' ')[0]
                                        : 'Corredor';

                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WorkoutDetailScreen(
                                                userName: firstName,
                                                workoutData: workout,
                                                isRestDay: isRestDay,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  if (isRestDay) ...[
                                    CircleAvatar(
                                      backgroundColor: isLight
                                          ? Colors.grey.shade200
                                          : const Color(0xFF2C2C35),
                                      radius: 20,
                                      child: Icon(
                                        Icons.nightlight_round,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      workout['title']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                workout['title']!,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            child: Text(
                                              workout['subtitle']!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  workout['duration']!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.flag_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  workout['distance']!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade500,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(
    String dayName,
    DateTime date,
    Color textColor, {
    bool hasWorkout = false,
  }) {
    final isToday =
        date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFFFF2D55) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected && !isToday
                  ? Border.all(color: const Color(0xFFFF2D55), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (hasWorkout)
            const Icon(Icons.directions_run, size: 14, color: Color(0xFFFF2D55))
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ============================================================
// TELA DE DETALHE DO TREINO COM TIMER
// ============================================================

class WorkoutDetailScreen extends StatefulWidget {
  final String userName;
  final Map<String, dynamic> workoutData;
  final bool isRestDay;

  const WorkoutDetailScreen({
    super.key,
    required this.userName,
    required this.workoutData,
    required this.isRestDay,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _selectedTab = 0; // 0: Ar livre, 1: Esteira, 2: Zonas de ritmo

  // === CONTROLE DO TIMER ===
  bool _isRunning = false;
  bool _isFinished = false;
  int _seconds = 0;
  Timer? _timer;
  String _realizedTime = '-';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isFinished = false;
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();

    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    final timeString = '$minutes:$secs';

    setState(() {
      _isRunning = false;
      _isFinished = true;
      _realizedTime = timeString;
    });

    // Tenta salvar no banco
    try {
      final workoutId = widget.workoutData['id'];
      if (workoutId != null) {
        await supabase
            .from('workouts')
            .update({'is_completed': true})
            .eq('id', workoutId);
      }
    } catch (e) {
      debugPrint('Erro ao salvar tempo realizado: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Treino finalizado! Tempo: $timeString'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final cardBgColor = isLight ? Colors.white : const Color(0xFF1C1C22);
    final chipBgColor = isLight
        ? const Color(0xFFF2F2F7)
        : const Color(0xFF26262E);
    final tableBgColor = isLight
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF18181C);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CABEÇALHO DO TREINO ---
            Text(
              widget.workoutData['title'] ?? 'Rodagem Contínua',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.workoutData['subtitle'] ?? '1 mês com a IA - Semana 1/17',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 18),

            // --- 2. CHIPS DE MÉTRICAS ---
            Row(
              children: [
                _buildMetricChip(
                  icon: Icons.timer_outlined,
                  text: widget.workoutData['duration'] ?? '30:00',
                  iconColor: const Color(0xFFFF2D55),
                  bgColor: chipBgColor,
                  textColor: textColor,
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.outlined_flag,
                  text: widget.workoutData['distance'] ?? '4,53 km',
                  iconColor: const Color(0xFFFF2D55),
                  bgColor: chipBgColor,
                  textColor: textColor,
                ),
                const SizedBox(width: 8),
                _buildMetricChip(
                  icon: Icons.favorite_outline,
                  text: widget.workoutData['carga'] ?? '6 ZP',
                  iconColor: const Color(0xFFFF2D55),
                  bgColor: chipBgColor,
                  textColor: textColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // === CRONÔMETRO (aparece quando inicia) ===
            if (_isRunning || _isFinished)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _isFinished ? 'Tempo Realizado' : 'Tempo em andamento',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isFinished ? _realizedTime : _formattedTime,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _isFinished
                            ? Colors.green
                            : const Color(0xFFFF2D55),
                      ),
                    ),
                  ],
                ),
              ),

            // --- 3. SEÇÃO DESCRIÇÃO ---
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isRestDay
                  ? '${widget.userName}, este é um dia fundamental para o seu descanso muscular. O descanso é o momento onde seu corpo reconstrói as fibras e evita o sobretreinamento.'
                  : '${widget.userName}, este é um treino essencial para a construção da sua durabilidade aeróbica. Corra em ritmo confortável, aquele em que você conseguiria conversar, e mantenha essa intensidade estável. Com isso, você fortalece seu sistema cardiovascular e melhora a capacidade de sustentar esforços prolongados.',
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isLight ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Aqueça antes de correr - ',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abrindo vídeo de aquecimento...'),
                        backgroundColor: Color(0xFFFF2D55),
                      ),
                    );
                  },
                  child: const Text(
                    'aprenda como aqui',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF2D55),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFFF2D55),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 4. ESTRUTURA DO TREINO ---
            Text(
              'Estrutura do treino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xFFEEEEEE)
                    : const Color(0xFF26262E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTabOption('Ar livre', 0, isLight),
                  _buildTabOption('Esteira', 1, isLight),
                  _buildTabOption('Zonas de ritmo', 2, isLight),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.directions_run,
                  color: Color(0xFFFF2D55),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.workoutData['title'] ?? 'Corrida Contínua',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight ? Colors.grey.shade200 : Colors.white10,
                ),
              ),
              child: Text(
                widget.workoutData['paceRange'] ??
                    '30:00 min entre 6:22 e 6:52 min/km',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. DADOS DO TREINO ---
            Text(
              'Dados do treino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tableBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Planejado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Realizado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTableRow(
                    'Duração',
                    widget.workoutData['duration'] ?? '30:00',
                    _isFinished ? _realizedTime : '-',
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTableRow(
                    'Distância',
                    widget.workoutData['distance'] ?? '4,53 km',
                    '-',
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTableRow(
                    'Ritmo médio',
                    widget.workoutData['pace'] ?? '6:37 /km',
                    '-',
                    textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTableRow(
                    'Carga',
                    widget.workoutData['carga'] ?? '6 ZP',
                    '-',
                    textColor,
                    showInfoIcon: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- 6. BOTÃO INICIAR / FINALIZAR ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.isRestDay
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dia de descanso registrado!'),
                            backgroundColor: Color(0xFFFF2D55),
                          ),
                        );
                      }
                    : _isFinished
                    ? null
                    : () {
                        if (_isRunning) {
                          _stopTimer();
                        } else {
                          _startTimer();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.orange
                      : _isFinished
                      ? Colors.green
                      : const Color(0xFFFF2D55),
                  disabledBackgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  widget.isRestDay
                      ? 'Registrar Descanso'
                      : _isFinished
                      ? 'Treino Finalizado ✓'
                      : _isRunning
                      ? 'Finalizar Treino'
                      : 'Iniciar Treino',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

  Widget _buildMetricChip({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption(String title, int index, bool isLight) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isLight ? Colors.white : const Color(0xFF3A3A42))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isLight ? Colors.black : Colors.white)
                  : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    String planned,
    String actual,
    Color textColor, {
    bool showInfoIcon = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (showInfoIcon) ...[
                const SizedBox(width: 4),
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            planned,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            actual,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: actual != '-' ? Colors.green : Colors.grey.shade500,
              fontWeight: actual != '-' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
