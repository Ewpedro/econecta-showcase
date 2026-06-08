import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/holerite.dart';
import '../../core/services/holerite_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_card.dart';
import '../../shared/widgets/shimmer_loading.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HoleriteProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.carregarHolerites,
              color: AppTheme.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, provider.user),
                  if (provider.isLoading)
                    const SliverFillRemaining(child: ShimmerDashboard())
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSaudacao(context, provider.user),
                          const SizedBox(height: 20),
                          _buildCardPrincipal(context, provider),
                          const SizedBox(height: 20),
                          _buildGridResumo(context, provider),
                          const SizedBox(height: 24),
                          _buildUltimoHolerite(context, provider),
                          const SizedBox(height: 24),
                          _buildGraficoBarra(context, provider),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserInfo? user) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.background,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF4FC3F7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Meus Holerites'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSaudacao(BuildContext context, UserInfo? user) {
    final hora = DateTime.now().hour;
    final saudacao = hora < 12
        ? 'Bom dia'
        : hora < 18
            ? 'Boa tarde'
            : 'Boa noite';
    final nome = user?.nome.split(' ').first ?? 'Usuário';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$saudacao, $nome! 👋',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          'Aqui está um resumo dos seus holerites',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildCardPrincipal(BuildContext context, HoleriteProvider provider) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final ultimo = provider.ultimoHolerite;

    return GradientCard(
      gradientColors: const [Color(0xFF1A73E8), Color(0xFF0D47A1)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Último Holerite',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              if (ultimo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ultimo.competencia,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ultimo != null ? fmt.format(ultimo.salarioLiquido) : 'R\$ ---',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 4),
          Text(
            'Salário Líquido',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _cardInfo(
                context,
                'Bruto',
                ultimo != null ? fmt.format(ultimo.salarioBruto) : '---',
                Icons.arrow_upward_rounded,
                Colors.greenAccent,
              ),
              const SizedBox(width: 16),
              _cardInfo(
                context,
                'Descontos',
                ultimo != null ? fmt.format(ultimo.totalDescontos) : '---',
                Icons.arrow_downward_rounded,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _cardInfo(
    BuildContext context,
    String label,
    String valor,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(valor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridResumo(BuildContext context, HoleriteProvider provider) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final fmtSimples = NumberFormat.currency(locale: 'pt_BR', symbol: '');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
          context,
          'Total ${DateTime.now().year}',
          fmt.format(provider.totalRecebidoAno),
          Icons.calendar_today_rounded,
          AppTheme.positive,
          delay: 300,
        ),
        _statCard(
          context,
          'Média Mensal',
          fmt.format(provider.mediaSalarialLiquido),
          Icons.trending_up_rounded,
          AppTheme.primary,
          delay: 400,
        ),
        _statCard(
          context,
          'Holerites',
          '${provider.holerites.length} disponíveis',
          Icons.receipt_long_rounded,
          AppTheme.warning,
          delay: 500,
        ),
        _statCard(
          context,
          'Baixados',
          '${provider.holerites.where((h) => h.baixado).length} PDFs',
          Icons.download_done_rounded,
          const Color(0xFF4FC3F7),
          delay: 600,
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String titulo,
    String valor,
    IconData icon,
    Color color, {
    int delay = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis),
              Text(titulo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      )),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).scale(
          begin: const Offset(0.9, 0.9),
        );
  }

  Widget _buildUltimoHolerite(BuildContext context, HoleriteProvider provider) {
    final ultimo = provider.ultimoHolerite;
    if (ultimo == null) return const SizedBox();
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalhes do Último', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _detalheRow(context, 'INSS', fmt.format(ultimo.inss), AppTheme.negative),
              _divider(),
              _detalheRow(context, 'IRRF', fmt.format(ultimo.irrf), AppTheme.negative),
              _divider(),
              _detalheRow(context, 'FGTS', fmt.format(ultimo.fgts), AppTheme.positive),
              ...ultimo.outrosDescontos.map((d) => Column(
                    children: [
                      _divider(),
                      _detalheRow(context, d.descricao, fmt.format(d.valor),
                          AppTheme.negative),
                    ],
                  )),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _detalheRow(
      BuildContext context, String label, String valor, Color valorColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(valor,
              style: TextStyle(
                color: valorColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: Color(0xFF2A3250), height: 1, thickness: 1);

  Widget _buildGraficoBarra(BuildContext context, HoleriteProvider provider) {
    if (provider.holertiesAnoAtual.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Líquido ${DateTime.now().year}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: provider.holertiesAnoAtual.map((h) {
              final max = provider.holertiesAnoAtual
                  .map((x) => x.salarioLiquido)
                  .reduce((a, b) => a > b ? a : b);
              final pct = max > 0 ? h.salarioLiquido / max : 0.0;
              final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(h.competencia,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12)),
                        Text(fmt.format(h.salarioLiquido),
                            style: const TextStyle(
                                color: AppTheme.positive,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }
}
