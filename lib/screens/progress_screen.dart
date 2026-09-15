import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedPeriod = 0; // 0: Semana, 1: Mês, 2: Ano

  // Mapeamento de eventos do calendário:
  // 'workout' = Treino (Ícone de Corredor)
  // 'race' = Prova (Ícone de Troféu)
  final Map<int, String> _calendarEvents = {
    2: 'workout',
    5: 'workout',
    9: 'workout',
    12: 'workout',
    14: 'workout', // Hoje
    18: 'workout',
    21: 'workout',
    27: 'race', // Exemplo de dia com Prova
  };

  int? _selectedDay = 14; // Dia selecionado por padrão

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Progresso',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFFF2D55),
              radius: 18,
              child: const Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BLOCO 1: SELETOR DE PERÍODO & GRÁFICO ---
            _buildCardWrapper(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodTab('Semana', 0, isDark),
                        _buildPeriodTab('Mês', 1, isDark),
                        _buildPeriodTab('Ano', 2, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Esta semana',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Últimas 12 semanas',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          top: 10,
                          right: 0,
                          child: Text(
                            '1km',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          right: 0,
                          child: Text(
                            '0.5km',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 0,
                          child: Text(
                            '0',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          left: 0,
                          right: 30,
                          child: Container(
                            height: 1,
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          left: 0,
                          right: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(12, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index == 11
                                      ? const Color(0xFFFF2D55)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF2D55),
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'JUL',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                'AGO',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                'SET',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Resumo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '14 SET – 20 SET',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildMetricCard(
                        'distância',
                        '0 km',
                        '0 km na semana anterior',
                        isDark,
                        isPrimary: true,
                      ),
                      _buildMetricCard(
                        'tempo',
                        '0m',
                        '0m na semana anterior',
                        isDark,
                      ),
                      _buildMetricCard(
                        'treinos',
                        '0',
                        '0 na semana anterior',
                        isDark,
                      ),
                      _buildMetricCard(
                        'carga',
                        '0 ZP',
                        '0 ZP na semana anterior',
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- BLOCO 2: MÊS COM A IA ---
            _buildCardWrapper(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 mês com a IA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          _buildChipTag('21K', isDark),
                          const SizedBox(width: 6),
                          _buildChipTag('10/jan', isDark),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Semana no ciclo: 1/17',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: 0.01,
                                strokeWidth: 10,
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF2D55),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '1%',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  'do ciclo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildCycleInfoRow(
                              Icons.flag_outlined,
                              'distância',
                              '0 m',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildCycleInfoRow(
                              Icons.timer_outlined,
                              'tempo correndo',
                              '0 min',
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildCycleInfoRow(
                              Icons.emoji_events_outlined,
                              'treinos',
                              '0',
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- BLOCO 3: ESTIMATIVAS DE PROVA ---
            _buildCardWrapper(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimativas de prova',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Baseado nos seus ritmos atuais',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildRaceEstimateCard('5K', '24:31', '4:54 /km', isDark),
                      _buildRaceEstimateCard(
                        '10K',
                        '51:25',
                        '5:09 /km',
                        isDark,
                      ),
                      _buildRaceEstimateCard(
                        '15K',
                        '1h20:44',
                        '5:23 /km',
                        isDark,
                      ),
                      _buildRaceEstimateCard(
                        '21K',
                        '1h56:18',
                        '5:31 /km',
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- BLOCO 4: CALENDÁRIO COM ÍCONES DE TREINO E TROFÉU ---
            _buildCardWrapper(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.chevron_left, size: 20),
                      Text(
                        'Setembro 2026',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _CalendarDayHeader('S'),
                      _CalendarDayHeader('T'),
                      _CalendarDayHeader('Q'),
                      _CalendarDayHeader('Q'),
                      _CalendarDayHeader('S'),
                      _CalendarDayHeader('S'),
                      _CalendarDayHeader('D'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildInteractiveCalendarGrid(isDark),

                  const SizedBox(height: 24),
                  Text(
                    'Resumo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '1 SET – 30 SET',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildMetricCard(
                        'tempo',
                        '0m',
                        '/ 0m',
                        isDark,
                        isPrimary: true,
                      ),
                      _buildMetricCard('distância', '0 km', '/ 0 km', isDark),
                      _buildMetricCard('treinos', '0', '/ 0', isDark),
                      _buildMetricCard('carga', '0 ZP', '/ 0 ZP', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- INTERACTIVITY DO CALENDÁRIO ---

  Widget _buildInteractiveCalendarGrid(bool isDark) {
    final days = [
      '',
      '',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '',
      '',
      '',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final dayText = days[index];
        if (dayText.isEmpty) return const SizedBox();

        final dayNum = int.parse(dayText);
        final eventType = _calendarEvents[dayNum];
        final isSelected = _selectedDay == dayNum;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = dayNum;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF2D55).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFFFF2D55), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFFF2D55)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (eventType != null) ...[
                  const SizedBox(height: 2),
                  Icon(
                    eventType == 'workout'
                        ? Icons.directions_run
                        : Icons.emoji_events,
                    size: 13,
                    color: eventType == 'workout'
                        ? const Color(0xFFFF2D55)
                        : Colors.amber,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HELPERS DE UI ---

  Widget _buildCardWrapper({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildPeriodTab(String title, int index, bool isDark) {
    bool isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String subtext,
    bool isDark, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFFF2D55)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isPrimary ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              color: isPrimary ? Colors.white70 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipTag(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildCycleInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRaceEstimateCard(
    String distance,
    String time,
    String pace,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            distance,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            pace,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayHeader extends StatelessWidget {
  final String day;
  const _CalendarDayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
    );
  }
}
