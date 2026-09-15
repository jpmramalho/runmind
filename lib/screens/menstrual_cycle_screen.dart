import 'package:flutter/material.dart';

class MenstrualCycleScreen extends StatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  State<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  String _currentPhase = 'Fase Folicular';
  bool _adjustWorkoutsAutomatically = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ciclo Menstrual',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pink.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.female, color: Colors.pink, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ajuste com base no seu ciclo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'A IA ajustará as cargas e intensidades das zonas de treino de acordo com a fase do seu ciclo.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Fase Atual do Ciclo:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _currentPhase,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                'Fase Menstrual',
                'Fase Folicular',
                'Fase Ovulatória',
                'Fase Lútea',
              ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _currentPhase = val!),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Ajustar treinos automaticamente',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Reduz o volume na fase menstrual e otimiza o pico de força na ovulatória.',
              ),
              value: _adjustWorkoutsAutomatically,
              activeColor: const Color(0xFFFF2D55),
              onChanged: (val) =>
                  setState(() => _adjustWorkoutsAutomatically = val),
            ),

            const SizedBox(height: 24),
            Text(
              'Recomendação para a fase selecionada:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Fase Folicular: Ótimo momento para treinos de intensidade alta e ganho de força. A energia e a recuperação estão em alta.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
