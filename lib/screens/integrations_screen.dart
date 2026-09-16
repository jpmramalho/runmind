import 'package:flutter/material.dart';

import '../main.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  // Lista de integrações com seus status locais de conexão
  final List<Map<String, dynamic>> _integrations = [
    {
      'id': 'strava',
      'name': 'Strava',
      'icon': Icons.directions_run,
      'color': const Color(0xFFFC4C02),
      'connected': false,
      'description': 'Sincronize suas corridas e segmentos automaticamente.',
    },
    {
      'id': 'garmin',
      'name': 'Garmin Connect',
      'icon': Icons.watch_outlined,
      'color': const Color(0xFF007CC3),
      'connected': false,
      'description': 'Importe métricas detalhadas do seu relógio Garmin.',
    },
    {
      'id': 'apple_health',
      'name': 'Apple Saúde',
      'icon': Icons.favorite,
      'color': const Color(0xFFFF2D55),
      'connected': false,
      'description': 'Sincronize dados de frequência cardíaca e treinos.',
    },
    {
      'id': 'google_fit',
      'name': 'Google Fit',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF4285F4),
      'connected': false,
      'description': 'Conecte seus treinos salvos na conta Google.',
    },
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntegrationStatuses();
  }

  // Carrega o status das conexões salvas no Supabase
  Future<void> _loadIntegrationStatuses() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('user_integrations')
            .select('provider, is_connected')
            .eq('user_id', user.id);

        if (data != null && mounted) {
          final connections = List<Map<String, dynamic>>.from(data);
          setState(() {
            for (var item in _integrations) {
              final match = connections.firstWhere(
                (c) => c['provider'] == item['id'],
                orElse: () => {},
              );
              if (match.isNotEmpty) {
                item['connected'] = match['is_connected'] ?? false;
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar integrações: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Alterna a conexão do serviço (Conectar / Desconectar)
  Future<void> _toggleIntegration(Map<String, dynamic> item) async {
    final newStatus = !item['connected'];
    final providerId = item['id'];
    final providerName = item['name'];

    setState(() {
      item['connected'] = newStatus;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('user_integrations').upsert({
          'user_id': user.id,
          'provider': providerId,
          'is_connected': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id, provider');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '$providerName conectado com sucesso!'
                : '$providerName desconectado.',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      // Reverte a alteração em caso de erro
      setState(() {
        item['connected'] = !newStatus;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar integração: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final cardBgColor = isLight ? Colors.white : const Color(0xFF1C1C22);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Integrações',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF2D55)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _integrations.length,
                itemBuilder: (context, index) {
                  final item = _integrations[index];
                  final isConnected = item['connected'] as bool;

                  return Card(
                    color: cardBgColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item['color'].withOpacity(0.15),
                          child: Icon(item['icon'], color: item['color']),
                        ),
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          item['description'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConnected
                                ? Colors.grey.shade800
                                : const Color(0xFFFF2D55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () => _toggleIntegration(item),
                          child: Text(
                            isConnected ? 'Desconectar' : 'Conectar',
                            style: TextStyle(
                              color: isConnected
                                  ? Colors.white70
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
