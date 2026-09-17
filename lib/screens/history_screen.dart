import 'package:flutter/material.dart';

import '../main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Lista das principais lesões em corredores
  final List<String> _commonInjuries = const [
    'Joelho de Corredor (Síndrome Patelofemoral)',
    'Canelite (Síndrome do Estresse Tibial)',
    'Fascite Plantar',
    'Tendinite de Aquiles',
    'Síndrome do Trato Iliotibial (TIT)',
    'Estiramento Muscular (Isquiotibiais/Panturrilha)',
    'Fratura por Estresse',
    'Entorse de Tornozelo',
    'Bursite no Quadril',
    'Outra',
  ];

  final List<String> _severityLevels = const ['Leve', 'Moderada', 'Grave'];

  // Busca o histórico de treinos do usuário
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

  // Função para marcar o fim da lesão (Recuperado)
  Future<void> _markInjuryAsRecovered(Map<String, dynamic> injury) async {
    DateTime endDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate:
          DateTime.tryParse(injury['start_date'] ?? '') ?? DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'SELECIONE A DATA EM QUE SE SENTIU BEM',
      confirmText: 'CONFIRMAR RECUPERAÇÃO',
      cancelText: 'CANCELAR',
    );

    if (pickedDate != null) {
      final formattedEndDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';

      try {
        await supabase
            .from('injuries')
            .update({'end_date': formattedEndDate})
            .eq('id', injury['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lesão marcada como recuperada! Parabéns! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        debugPrint('Erro ao atualizar fim da lesão: $e');
      }
    }
  }

  // Função para Criar ou Editar uma Lesão
  Future<void> _showInjuryDialog({Map<String, dynamic>? injury}) async {
    final isEditing = injury != null;
    String selectedInjury =
        injury != null && _commonInjuries.contains(injury['description'])
        ? injury['description']
        : _commonInjuries.first;

    TextEditingController customInjuryController = TextEditingController(
      text: (injury != null && !_commonInjuries.contains(injury['description']))
          ? injury['description']
          : '',
    );

    DateTime startDate = injury != null && injury['start_date'] != null
        ? DateTime.tryParse(injury['start_date']) ?? DateTime.now()
        : DateTime.now();

    DateTime? endDate = injury != null && injury['end_date'] != null
        ? DateTime.tryParse(injury['end_date'])
        : null;

    String selectedSeverity = injury != null && injury['severity'] != null
        ? injury['severity']
        : 'Moderada';

    TextEditingController notesController = TextEditingController(
      text: injury?['notes'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C22),
              title: Text(
                isEditing ? 'Editar Lesão' : 'Registrar Nova Lesão',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lesão',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedInjury,
                      dropdownColor: const Color(0xFF262632),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262632),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _commonInjuries.map((injuryName) {
                        return DropdownMenuItem(
                          value: injuryName,
                          child: Text(
                            injuryName,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedInjury = value);
                        }
                      },
                    ),
                    if (selectedInjury == 'Outra') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customInjuryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Especifique a lesão',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF262632),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Data de Início',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262632),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Data do Fim / Recuperação (Opcional)',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: startDate,
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262632),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              endDate != null
                                  ? '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}'
                                  : 'Em recuperação (sem fim)',
                              style: TextStyle(
                                color: endDate != null
                                    ? Colors.white
                                    : Colors.amber,
                              ),
                            ),
                            Row(
                              children: [
                                if (endDate != null)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setDialogState(() => endDate = null);
                                    },
                                  ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.event_available,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gravidade',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedSeverity,
                      dropdownColor: const Color(0xFF262632),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262632),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _severityLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedSeverity = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Observações / Sintomas (opcional)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF262632),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final user = supabase.auth.currentUser;
                    if (user == null) return;

                    final descriptionText = selectedInjury == 'Outra'
                        ? customInjuryController.text.trim()
                        : selectedInjury;

                    if (descriptionText.isEmpty) return;

                    final formattedStartDate =
                        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

                    final formattedEndDate = endDate != null
                        ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                        : null;

                    final payload = {
                      'user_id': user.id,
                      'description': descriptionText,
                      'start_date': formattedStartDate,
                      'end_date': formattedEndDate,
                      'severity': selectedSeverity,
                      'notes': notesController.text.trim(),
                    };

                    try {
                      if (isEditing) {
                        await supabase
                            .from('injuries')
                            .update(payload)
                            .eq('id', injury['id']);
                      } else {
                        await supabase.from('injuries').insert(payload);
                      }
                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {});
                      }
                    } catch (e) {
                      debugPrint('Erro ao salvar lesão: $e');
                    }
                  },
                  child: Text(
                    isEditing ? 'Atualizar' : 'Salvar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Função para Excluir Lesão
  Future<void> _deleteInjury(String injuryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C22),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja realmente remover este registro de lesão?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('injuries').delete().eq('id', injuryId);
        setState(() {});
      } catch (e) {
        debugPrint('Erro ao excluir lesão: $e');
      }
    }
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'Leve':
        return Colors.amber;
      case 'Grave':
        return Colors.red;
      case 'Moderada':
      default:
        return Colors.orange;
    }
  }

  // Função para formatar data BR (AAAA-MM-DD -> DD/MM/AAAA)
  String _formatDateBR(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return dateStr;
  }

  // Função auxiliar para calcular dias de duração da lesão
  int? _calculateDaysDuration(String? startDateStr, String? endDateStr) {
    if (startDateStr == null) return null;
    final start = DateTime.tryParse(startDateStr);
    final end = endDateStr != null
        ? DateTime.tryParse(endDateStr)
        : DateTime.now();
    if (start == null || end == null) return null;
    return end.difference(start).inDays;
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
                    child: Text(
                      'Nenhum treino registrado ainda.',
                      style: TextStyle(color: Colors.grey),
                    ),
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
                        subtitle: Text(
                          'Início: ${_formatDateBR(startDate)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
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

                return Stack(
                  children: [
                    injuries.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum registro de lesão.\nClique no botão abaixo para adicionar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom: 80,
                            ),
                            itemCount: injuries.length,
                            itemBuilder: (context, index) {
                              final item = injuries[index];
                              final description =
                                  item['description'] ??
                                  'Lesão não especificada';
                              final startDateStr = item['start_date'];
                              final endDateStr = item['end_date'];
                              final severity = item['severity'] ?? 'Moderada';
                              final notes = item['notes'] ?? '';

                              final isRecovered =
                                  endDateStr != null &&
                                  endDateStr.toString().isNotEmpty;
                              final durationDays = _calculateDaysDuration(
                                startDateStr,
                                endDateStr,
                              );

                              return Card(
                                color: cardBgColor,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: isRecovered
                                                ? Colors.green
                                                : _getSeverityColor(severity),
                                            child: Icon(
                                              isRecovered
                                                  ? Icons.check_circle_outline
                                                  : Icons.healing,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getSeverityColor(
                                                              severity,
                                                            ).withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Gravidade: $severity',
                                                        style: TextStyle(
                                                          color:
                                                              _getSeverityColor(
                                                                severity,
                                                              ),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (isRecovered
                                                                    ? Colors
                                                                          .green
                                                                    : Colors
                                                                          .amber)
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        isRecovered
                                                            ? 'Recuperado ✅'
                                                            : 'Em recuperação 🩹',
                                                        style: TextStyle(
                                                          color: isRecovered
                                                              ? Colors.green
                                                              : Colors.amber,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Início: ${_formatDateBR(startDateStr)}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  'Fim: ${isRecovered ? _formatDateBR(endDateStr) : 'Em andamento'}',
                                                  style: TextStyle(
                                                    color: isRecovered
                                                        ? Colors.grey
                                                        : Colors.amber,
                                                    fontSize: 13,
                                                    fontWeight: isRecovered
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                                  ),
                                                ),
                                                if (durationDays != null) ...[
                                                  Text(
                                                    'Duração: $durationDays dia(s)${isRecovered ? '' : ' até hoje'}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                                if (notes.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Obs: $notes',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _showInjuryDialog(
                                                      injury: item,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                onPressed: () => _deleteInjury(
                                                  item['id'].toString(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (!isRecovered) ...[
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Colors.green,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _markInjuryAsRecovered(item),
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Estou bem! Marcar Fim da Lesão',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.extended(
                        backgroundColor: const Color(0xFFFF2D55),
                        onPressed: () => _showInjuryDialog(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Nova Lesão',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
