import 'package:flutter/material.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Lista de Treinos',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
