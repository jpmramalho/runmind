import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Lista de grupos disponíveis
  final List<Map<String, dynamic>> _availableGroups = [
    {
      'name': 'Pelotão Recife',
      'members': '191 membros',
      'tag': 'REC',
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Pelotão São Paulo',
      'members': '1.099 membros',
      'tag': 'SP',
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Pelotão Belo Horizonte',
      'members': '400 membros',
      'tag': 'BH',
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Cupons & Promos',
      'members': '1.600 membros',
      'icon': Icons.confirmation_number_outlined,
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Pelotão: primeiros 21km',
      'members': '599 membros',
      'tag': '21',
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Classificados',
      'members': '359 membros',
      'icon': Icons.local_offer_outlined,
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Pelotão: primeiros 10km',
      'members': '577 membros',
      'tag': '10',
      'isNew': true,
      'isJoined': false,
    },
    {
      'name': 'Pelotão: primeiros 5km',
      'members': '1.164 membros',
      'tag': '5',
      'isNew': true,
      'isJoined': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final joinedGroups = _availableGroups
        .where((group) => group['isJoined'] == true)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Conversas',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF2D55),
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Disponíveis'),
            Tab(text: 'Minhas conversas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Disponíveis
          _buildGroupList(_availableGroups, isDark),
          // Aba 2: Minhas Conversas
          joinedGroups.isEmpty
              ? _buildEmptyState(isDark)
              : _buildGroupList(joinedGroups, isDark),
        ],
      ),
    );
  }

  Widget _buildGroupList(List<Map<String, dynamic>> groups, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Campo de Pesquisa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Pesquisar',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Lista de grupos
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: groups.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupTile(group, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Ícone redondo do grupo
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: group['icon'] != null
                ? Icon(
                    group['icon'] as IconData,
                    color: const Color(0xFFFF2D55),
                    size: 24,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions_run,
                        color: Color(0xFFFF2D55),
                        size: 18,
                      ),
                      if (group['tag'] != null)
                        Text(
                          group['tag'],
                          style: const TextStyle(
                            color: Color(0xFFFF2D55),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(width: 14),
          // Título e membros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${group['isNew'] == true ? 'Novo · ' : ''}${group['members']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Botão Entrar / Sair
          ElevatedButton(
            onPressed: () {
              setState(() {
                group['isJoined'] = !(group['isJoined'] as bool);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: group['isJoined']
                  ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                  : const Color(0xFF1E7046), // Cor verde exata da imagem
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              group['isJoined'] ? 'Sair' : 'Entrar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: group['isJoined']
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            'Você ainda não entrou em nenhuma conversa.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
