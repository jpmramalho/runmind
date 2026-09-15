import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workout['title'] ?? 'Treino',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '1 mês com a IA - ${widget.workout['week'] ?? 'Semana 1/17'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTag(
                  Icons.access_time,
                  widget.workout['duration'] ?? '31:30',
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildTag(
                  Icons.flag_outlined,
                  widget.workout['distance'] ?? '4,44 km',
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildTag(Icons.aspect_ratio, '6,5 ZP', isDark),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Júlia, hoje você vai brincar com os ritmos. As variações vão estimular sua potência aeróbica e sua capacidade de mudança de ritmo, além de melhorar a coordenação e a eficiência ao alternar intensidades.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: const Text.rich(
                TextSpan(
                  text: 'Aqueça antes de correr - aprenda como ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  children: [
                    TextSpan(
                      text: 'aqui',
                      style: TextStyle(
                        color: Color(0xFFFF2D55),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Estrutura do treino',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTabOption('Ar livre', 0, isDark),
                  _buildTabOption('Esteira', 1, isDark),
                  _buildTabOption('Zonas de ritmo', 2, isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildStepItem(
              stepNumber: '1',
              icon: Icons.directions_run,
              title: 'Aquecimento',
              detailText: '10:00 min entre 6:22 e 6:52 min/km',
              isDark: isDark,
              hasConnector: true,
            ),
            _buildStepItem(
              stepNumber: '2',
              icon: Icons.repeat,
              title: 'Repetir 6 vezes',
              detailText: '45 seg entre 5:32 e 5:42 min/km',
              isDark: isDark,
              hasConnector: false,
            ),
            const SizedBox(height: 24),

            // --- BLOCO: COMO EXECUTAR ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF2D55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Como executar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Comece correndo 10 minutos entre 6:22 e 6:52 por km. Depois, faça 6 repetições iguais. Em cada repetição, corra 45 segundos entre 5:32 e 5:42 por km, caminhe 1 minuto para recuperar e depois corra 1 minuto entre 6:22 e 6:52 por km. Quando terminar as 6 repetições, feche correndo 5 minutos entre 6:22 e 6:52 por km.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- BLOCO: DADOS DO TREINO ---
            Text(
              'Dados do treino',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Cabeçalho da tabela
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                        child: Text(
                          'Planejado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Realizado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    'Duração',
                    widget.workout['duration'] ?? '31:30',
                    '-',
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    'Distância',
                    widget.workout['distance'] ?? '4,44 km',
                    '-',
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow('Ritmo médio', '7:06 /km', '-', isDark),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    'Carga',
                    '6,5 ZP',
                    '-',
                    isDark,
                    showInfoIcon: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(
    String label,
    String planned,
    String actual,
    bool isDark, {
    bool showInfoIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
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
          child: Text(
            planned,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            actual,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF2D55)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption(String title, int index, bool isDark) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.grey.shade800 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
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

  Widget _buildStepItem({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String detailText,
    required bool isDark,
    required bool hasConnector,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (hasConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFFFF2D55)),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    detailText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
