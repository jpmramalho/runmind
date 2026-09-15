import 'package:flutter/material.dart';

class StrengthenScreen extends StatelessWidget {
  const StrengthenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Fortalecimento',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '1 mês com a IA - Semana 1/17',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'tente fazer em dias sem corrida, mas se não der faça quando conseguir e já estará incrível!',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),

          _buildWorkoutCard(
            context: context,
            title: 'Mobilidade e Ativação de Quadril',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildWorkoutCard(
            context: context,
            title: 'Fortalecimento Pélvico e Adutores',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard({
    required BuildContext context,
    required String title,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(title: title),
          ),
        );
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : const Color(0xFF23242A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.fitness_center,
                size: 48,
                color: Color(0xFFFF2D55),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutDetailScreen extends StatelessWidget {
  final String title;
  const WorkoutDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Equipamentos Necessários',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip('Rolo de liberação', isDark),
              const SizedBox(width: 8),
              _buildChip('Miniband', isDark),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Descrição',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Treino voltado para a mobilidade e ativação do complexo do quadril com ênfase em movimentos unilaterais. Desenvolve estabilidade lateral e controle neuromuscular.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          Text(
            'Blocos de Treino',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          _buildBlockSection('Preparação', [
            {'title': 'Rolinho Banda Iliotibial', 'sub': '1 min cada perna'},
            {'title': 'Rolinho Glúteo Médio', 'sub': '1 min cada lado'},
          ], isDark),

          _buildBlockSection('Alongamento Dinâmico', [
            {'title': 'Flexão de Quadril', 'sub': '20 repetições alternadas'},
            {'title': 'Glúteo Médio', 'sub': '20 repetições alternadas'},
          ], isDark),

          _buildBlockSection('Ativações', [
            {
              'title': 'Passada Lateral com Mini-band',
              'sub': '3 séries de 12 passos cada lado',
            },
            {
              'title': 'Prancha Lateral',
              'sub': '3 séries de 30 segundos cada lado',
            },
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBlockSection(
    String header,
    List<Map<String, String>> items,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Text(
            header,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              var item = entry.value;
              return ListTile(
                leading: Text(
                  '$idx',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item['sub']!,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
