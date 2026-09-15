import 'package:flutter/material.dart';

class AdjustWorkoutsScreen extends StatefulWidget {
  const AdjustWorkoutsScreen({super.key});

  @override
  State<AdjustWorkoutsScreen> createState() => _AdjustWorkoutsScreenState();
}

class _AdjustWorkoutsScreenState extends State<AdjustWorkoutsScreen> {
  final List<String> _days = ['seg', 'ter', 'qua', 'qui', 'sex', 'sab', 'dom'];
  final Set<String> _selectedDays = {'ter', 'qui', 'sab', 'dom'};

  String _referenceDistance = '5 km';
  String _bestTime = '00:26:39';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ajustar treinos',
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
              'Dias de treino:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _days.map((day) {
                bool isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.grey.shade600
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Text(
              'Distância de referência:',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _referenceDistance,
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
                '21 km',
                '42 km',
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _referenceDistance = val!),
            ),

            const SizedBox(height: 20),

            Text(
              'Seu melhor tempo:',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _bestTime,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                '00:26:39',
                '00:25:00',
                '00:28:30',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _bestTime = val!),
            ),

            const SizedBox(height: 24),

            // Tabela de Zonas de Treino
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'zonas de treino i',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'min/km',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'km/h',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildZoneRow(
                    'zona 2 (Z2)',
                    '6:22 - 6:52',
                    '9,4 - 8,7',
                    isDark,
                  ),
                  _buildZoneRow(
                    'zona 3 (Z3)',
                    '5:42 - 6:22',
                    '10,5 - 9,4',
                    isDark,
                  ),
                  _buildZoneRow(
                    'zona 4 (Z4)',
                    '5:32 - 5:42',
                    '10,8 - 10,5',
                    isDark,
                  ),
                  _buildZoneRow(
                    'zona 5A (Z5a)',
                    '4:57 - 5:32',
                    '12,1 - 10,8',
                    isDark,
                  ),
                  _buildZoneRow(
                    'zona 5B (Z5b)',
                    '4:37 - 4:57',
                    '13,0 - 12,1',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Botão Recalcular meus treinos
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Treinos recalculados com sucesso!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Recalcular meus treinos',
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

  Widget _buildZoneRow(String zone, String minKm, String kmh, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(minKm, style: TextStyle(color: Colors.grey.shade600)),
          Text(kmh, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
