import 'package:flutter/material.dart';

import '../main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Busca os treinos do usuário
  Future<List<Map<String, dynamic>>> _fetchWorkoutHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await supabase
          .from('workouts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erro ao buscar histórico de treinos: $e');
      return [];
    }
  }

  // Busca o histórico de lesões do usuário
  Future<List<Map<String, dynamic>>> _fetchInjuryHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await supabase
          .from('injuries')
          .select()
          .eq('user_id', user.id)
          .order('start_date', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erro ao buscar histórico de lesões: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final cardBgColor = isLight ? Colors.white : const Color(0xFF1C1C22);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Histórico Completo',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF2D55),
            labelColor: Color(0xFFFF2D55),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.fitness_center), text: 'Treinos'),
              Tab(icon: Icon(Icons.healing), text: 'Lesões'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- ABA 1: TREINOS ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchWorkoutHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
                  );
                }

                final workouts = snapshot.data ?? [];

                if (workouts.isEmpty) {
                  return const Center(
                    child: Text('Nenhum treino registrado ainda.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final item = workouts[index];
                    final title = item['title'] ?? 'Treino de Corrida';
                    final startDate = item['created_at'] != null
                        ? item['created_at'].toString().substring(0, 10)
                        : 'Data não informada';

                    return Card(
                      color: cardBgColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFF2D55),
                          child: Icon(
                            Icons.directions_run,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text('Início: $startDate'),
                      ),
                    );
                  },
                );
              },
            ),

            // --- ABA 2: LESÕES ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchInjuryHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
                  );
                }

                final injuries = snapshot.data ?? [];

                if (injuries.isEmpty) {
                  return const Center(child: Text('Nenhum registro de lesão.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: injuries.length,
                  itemBuilder: (context, index) {
                    final item = injuries[index];
                    final description =
                        item['description'] ?? 'Lesão não especificada';
                    final startDate =
                        item['start_date'] ?? 'Data não informada';
                    final endDate =
                        item['end_date'] ?? 'Em recuperação (Sem data final)';

                    return Card(
                      color: cardBgColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.healing, color: Colors.white),
                        ),
                        title: Text(
                          description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Início: $startDate'),
                            Text('Fim: $endDate'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
