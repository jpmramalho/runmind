import 'package:flutter/material.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Privacidade e Termos',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termos de Uso e Política de Privacidade — RUNMIND',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Última atualização: 17 de setembro de 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bem-vindo ao RUNMIND. Ao utilizar nosso aplicativo, você concorda com estes Termos de Uso e com a nossa Política de Privacidade. Recomendamos a leitura atenta deste documento.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '1. Sobre o RUNMIND',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O RUNMIND é uma plataforma voltada para o acompanhamento e planejamento de treinos de corrida e atividades físicas. O aplicativo disponibiliza planos de treino, acompanhamento de métricas e ferramentas de evolução para atletas de diversos níveis.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '2. Isenção de Responsabilidade Médica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Os planos e recomendações disponibilizados no RUNMIND possuem caráter informativo e educacional.\n'
                      '• O aplicativo NÃO substitui o acompanhamento profissional de um médico, educador físico ou nutricionista.\n'
                      '• Antes de iniciar qualquer programa de exercícios, recomendamos que você consulte um médico para avaliar sua aptidão física. O uso das planilhas e treinos é de sua total responsabilidade.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '3. Coleta e Uso de Dados (Privacidade)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Respeitamos a sua privacidade e garantimos a proteção dos seus dados pessoais conforme as diretrizes da LGPD (Lei Geral de Proteção de Dados):\n\n'
                      '• Dados Cadastrais: Nome, e-mail e informações do perfil para personalização da sua experiência.\n'
                      '• Dados de Treino: Histórico de atividades, distâncias, ritmos e métricas de desempenho.\n'
                      '• Uso das Informações: Os dados coletados são utilizados exclusivamente para o funcionamento dos recursos do aplicativo.\n'
                      '• Compartilhamento: O RUNMIND não vende ou compartilha seus dados pessoais com terceiros.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '4. Responsabilidades do Usuário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Manter suas credenciais de acesso seguras e confidenciais.\n'
                      '• Garantir que as informações fornecidas no cadastro sejam verdadeiras.\n'
                      '• Utilizar a plataforma de forma ética e em conformidade com as leis vigentes.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '5. Propriedade Intelectual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todo o conteúdo do RUNMIND — incluindo marcas, logotipos, textos, layouts, algoritmos de treino e código-fonte — é de propriedade exclusiva dos desenvolvedores do projeto.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '6. Contato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Em caso de dúvidas ou solicitações relacionadas aos seus dados pessoais, entre em contato através da aba Perfil no aplicativo.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Entendi e Concordo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
