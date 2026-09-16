class WorkoutTemplates {
  static final Map<String, List<Map<String, dynamic>>> templates = {
    'Iniciante': [
      {
        'day': 'Segunda-feira',
        'title': 'Caminhada + Trote',
        'description': '5 min caminhada + 10x (1 min trote / 1 min caminhada)',
        'duration_min': 30,
      },
      {
        'day': 'Quarta-feira',
        'title': 'Fortalecimento',
        'description':
            'Exercícios de mobilidade e fortalecimento de joelho/tornozelo',
        'duration_min': 20,
      },
      {
        'day': 'Sexta-feira',
        'title': 'Trote Contínuo',
        'description': '15 min de trote leve sem parar',
        'duration_min': 20,
      },
      {
        'day': 'Domingo',
        'title': 'Caminhada Longa',
        'description': '40 min de caminhada em ritmo constante',
        'duration_min': 40,
      },
    ],
    'Casual': [
      {
        'day': 'Terça-feira',
        'title': 'Corrida Leve',
        'description': '3 km em ritmo confortável (Pace leve)',
        'duration_min': 25,
      },
      {
        'day': 'Quinta-feira',
        'title': 'Treino de Ritmo',
        'description':
            '1 km aquecimento + 2 km ritmo moderado + 1 km desaquecimento',
        'duration_min': 30,
      },
      {
        'day': 'Sábado',
        'title': 'Longão Casual',
        'description': '5 km de corrida contínua',
        'duration_min': 40,
      },
    ],
    'Intermediário': [
      {
        'day': 'Terça-feira',
        'title': 'Treino Intervalado (Tiro)',
        'description':
            '1 km aquecimento + 6x 400m forte (rec. 90s) + 1 km desaquecimento',
        'duration_min': 40,
      },
      {
        'day': 'Quinta-feira',
        'title': 'Tempo Run',
        'description': '1 km aquecimento + 4 km no ritmo de prova + 1 km leve',
        'duration_min': 45,
      },
      {
        'day': 'Sábado',
        'title': 'Regenerativo',
        'description': '4 km rodagem bem leve',
        'duration_min': 30,
      },
      {
        'day': 'Domingo',
        'title': 'Longão Intermediário',
        'description': '10 km a 12 km num ritmo aeróbico confortável',
        'duration_min': 75,
      },
    ],
    'Avançado': [
      {
        'day': 'Segunda-feira',
        'title': 'Rodagem Leve',
        'description': '8 km regenerativo',
        'duration_min': 45,
      },
      {
        'day': 'Terça-feira',
        'title': 'Tiros Longos',
        'description': '2 km aquecimento + 4x 1000m forte (rec. 2 min) + 2 km desaquecimento',
        'duration_min': 55,
      },
      {
        'day': 'Quinta-feira',
        'title': 'Tempo Run Progressivo',
        'description': '8 km aumentando o ritmo a cada 2 km',
        'duration_min': 50,
      },
      {
        'day': 'Sábado',
        'title': 'Rodagem Moderada',
        'description': '10 km em ritmo ritmado',
        'duration_min': 55,
      },
      {
        'day': 'Domingo',
        'title': 'Longão de Performance',
        'description': '18 km a 21 km com os últimos 3 km no pace de prova',
        'duration_min': 110,
      },
    ],
    'Profissional / Elite': [
      {
        'day': 'Segunda-feira',
        'title': 'Rodagem Dupla',
        'description': 'Manhã: 10 km leve / Tarde: 6 km regenerativo',
        'duration_min': 80,
      },
      {
        'day': 'Terça-feira',
        'title': 'Intervalado de Pista',
        'description':
            '3 km aquecimento + 10x 800m ritmo VO2Max + 3 km desaquecimento',
        'duration_min': 70,
      },
      {
        'day': 'Quarta-feira',
        'title': 'Rodagem Aeróbica',
        'description': '14 km moderado',
        'duration_min': 70,
      },
      {
        'day': 'Quinta-feira',
        'title': 'Fartlek',
        'description': '2 km aquecimento + 10x (2 min forte / 1 min leve) + 2 km desaquecimento',
        'duration_min': 60,
      },
      {
        'day': 'Sexta-feira',
        'title': 'Regenerativo',
        'description': '8 km muito leve',
        'duration_min': 45,
      },
      {
        'day': 'Sábado',
        'title': 'Longão Específico',
        'description': '28 km a 32 km com trechos em ritmo de maratona',
        'duration_min': 150,
      },
    ],
  };
}
