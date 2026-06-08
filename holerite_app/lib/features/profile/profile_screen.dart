import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/holerite_provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HoleriteProvider>(
          builder: (context, provider, _) {
            final user = provider.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Perfil', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),

                  // Avatar e nome
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFF4FC3F7)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.nome.isNotEmpty == true
                                  ? user!.nome[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.nome ?? 'Usuário',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (user?.cargo.isNotEmpty == true)
                          Text(user!.cargo,
                              style: Theme.of(context).textTheme.bodyMedium),
                        if (user?.orgao.isNotEmpty == true)
                          Text(user!.orgao,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.primary)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Infos
                  if (user?.matricula.isNotEmpty == true)
                    _infoCard(context, 'Matrícula', user!.matricula,
                        Icons.badge_outlined),
                  const SizedBox(height: 12),

                  // Estatísticas
                  _infoCard(context, 'Total de Holerites',
                      '${provider.holerites.length}', Icons.receipt_long_rounded),
                  const SizedBox(height: 12),
                  _infoCard(
                      context,
                      'PDFs Salvos',
                      '${provider.holerites.where((h) => h.baixado).length}',
                      Icons.download_done_rounded),

                  const SizedBox(height: 32),

                  // Configurações
                  _secao(context, 'Configurações'),
                  _opcao(context, 'Sincronização automática',
                      Icons.sync_rounded, () {}),
                  _opcao(context, 'Notificações', Icons.notifications_outlined, () {}),
                  _opcao(context, 'Como configurar a API',
                      Icons.help_outline_rounded, () => _mostrarGuiaApi(context)),

                  const SizedBox(height: 16),

                  // Sair
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.negative,
                      side: const BorderSide(color: AppTheme.negative),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sair'),
                    onPressed: () => _confirmarSaida(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, String label, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11)),
              Text(valor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secao(BuildContext context, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(titulo,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _opcao(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sair', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Deseja sair do aplicativo?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Sair', style: TextStyle(color: AppTheme.negative)),
          ),
        ],
      ),
    );
  }

  void _mostrarGuiaApi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GuiaApiSheet(),
    );
  }
}

class _GuiaApiSheet extends StatelessWidget {
  const _GuiaApiSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: ctrl,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Como descobrir os endpoints da API',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _passo(context, '1', 'Abra o Chrome no computador e acesse fitcard.app.questorpublico.com.br'),
            _passo(context, '2', 'Pressione F12 para abrir o DevTools'),
            _passo(context, '3', 'Clique na aba "Network" (Rede)'),
            _passo(context, '4', 'Faça login no site'),
            _passo(context, '5', 'Navegue até a página de holerites'),
            _passo(context, '6', 'Observe as requisições que aparecem — procure por /api/, /holerite, /contracheque'),
            _passo(context, '7', 'Clique em uma requisição e veja: URL, Headers (Authorization) e Response'),
            _passo(context, '8', 'Atualize o arquivo api_client.dart com as URLs e headers corretos'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Text(
                '💡 Dica: o token que você tem (259bd...) pode ser o valor do cookie de sessão ou um Bearer token. Verifique o header "Authorization" nas requisições.',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passo(BuildContext context, String num, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
