import 'package:flutter/material.dart';

class ChangeGoalScreen extends StatefulWidget {
  const ChangeGoalScreen({super.key});

  @override
  State<ChangeGoalScreen> createState() => _ChangeGoalScreenState();
}

class _ChangeGoalScreenState extends State<ChangeGoalScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: '1 mês com a IA',
  );
  final TextEditingController _startDateController = TextEditingController(
    text: '14/09/2026',
  );
  final TextEditingController _targetDateController = TextEditingController(
    text: '10/01/2027',
  );

  String _selectedDistance = 'Meia-maratona (21,1 km)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mudar Objetivo',
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
            Text(
              'Dê um nome para o seu objetivo: *',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Quando você vai começar a treinar? *',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Qual a distância do seu objetivo? *',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDistance,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                '5 km',
                '10 km',
                'Meia-maratona (21,1 km)',
                'Maratona (42,2 km)',
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDistance = val!),
            ),
            const SizedBox(height: 20),

            Text(
              'Quando quer atingir o seu objetivo? (opcional)',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetDateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              '(*): 6 meses (24 semanas) é a duração máxima para um ciclo de treinamento de corrida. Se a sua meta estiver mais distante, comece com uma meta intermediária e, quando faltar 6 meses para o alvo principal, inicie um novo ciclo por aqui.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Mudar Objetivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
