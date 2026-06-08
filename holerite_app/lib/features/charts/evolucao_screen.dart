import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/holerite.dart';
import '../../core/services/holerite_provider.dart';
import '../../core/theme/app_theme.dart';

class EvolucaoScreen extends StatefulWidget {
  const EvolucaoScreen({super.key});

  @override
  State<EvolucaoScreen> createState() => _EvolucaoScreenState();
}

class _EvolucaoScreenState extends State<EvolucaoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _anoSelecionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HoleriteProvider>(
          builder: (context, provider, _) {
            final anos = provider.holeritesPorAno.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            if (anos.isEmpty) {
              return const Center(
                child: Text('Sem dados para exibir'),
              );
            }

            final holeritesAno = provider.holeritesPorAno[_anoSelecionado] ??
                provider.holertiesAnoAtual;

            return Column(
              children: [
                _buildHeader(context, anos),
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  tabs: const [
                    Tab(text: 'Líquido'),
                    Tab(text: 'Descontos'),
                    Tab(text: 'Comparativo'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabLiquido(context, holeritesAno),
                      _buildTabDescontos(context, holeritesAno),
                      _buildTabComparativo(context, provider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<int> anos) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Evolução Salarial',
              style: Theme.of(context).textTheme.titleLarge),
          DropdownButton<int>(
            value: _anoSelecionado,
            dropdownColor: AppTheme.surface,
            style: const TextStyle(color: AppTheme.textPrimary),
            underline: const SizedBox(),
            items: anos
                .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                .toList(),
            onChanged: (v) => setState(() => _anoSelecionado = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLiquido(
      BuildContext context, List<Holerite> holerites) {
    if (holerites.isEmpty) return _buildSemDados();

    final sorted = [...holerites]..sort((a, b) => a.mes.compareTo(b.mes));
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final maximo = sorted.map((h) => h.salarioLiquido).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResumoAnual(context, sorted, fmt),
          const SizedBox(height: 20),
          Container(
            height: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(_buildLineChart(sorted, maximo)),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          _buildListaMeses(context, sorted, fmt),
        ],
      ),
    );
  }

  Widget _buildResumoAnual(
      BuildContext context, List<Holerite> holerites, NumberFormat fmt) {
    final total = holerites.fold(0.0, (s, h) => s + h.salarioLiquido);
    final media = total / holerites.length;
    final maior = holerites.map((h) => h.salarioLiquido).reduce((a, b) => a > b ? a : b);
    final menor = holerites.map((h) => h.salarioLiquido).reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        Expanded(child: _resumoCard(context, 'Total', fmt.format(total), AppTheme.primary)),
        const SizedBox(width: 10),
        Expanded(child: _resumoCard(context, 'Média', fmt.format(media), AppTheme.positive)),
        const SizedBox(width: 10),
        Expanded(child: _resumoCard(context, 'Maior', fmt.format(maior), AppTheme.warning)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _resumoCard(BuildContext context, String label, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  color: cor, fontWeight: FontWeight.w700, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  LineChartData _buildLineChart(List<Holerite> sorted, double maximo) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => const FlLine(
          color: Color(0xFF2A3250),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, meta) {
              const meses = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
              final idx = v.toInt();
              if (idx < 0 || idx >= meses.length) return const SizedBox();
              return Text(meses[idx],
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: sorted
              .map((h) => FlSpot((h.mes - 1).toDouble(), h.salarioLiquido))
              .toList(),
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
              radius: 4,
              color: AppTheme.primary,
              strokeWidth: 2,
              strokeColor: AppTheme.cardColor,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primary.withOpacity(0.1),
          ),
        ),
      ],
      minY: 0,
      maxY: maximo * 1.2,
    );
  }

  Widget _buildListaMeses(
      BuildContext context, List<Holerite> sorted, NumberFormat fmt) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Por Mês', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...sorted.asMap().entries.map((entry) {
          final h = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    meses[h.mes - 1].substring(0, 3),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: h.salarioLiquido /
                          sorted
                              .map((x) => x.salarioLiquido)
                              .reduce((a, b) => a > b ? a : b),
                      minHeight: 8,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: Text(
                    fmt.format(h.salarioLiquido),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppTheme.positive,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabDescontos(
      BuildContext context, List<Holerite> holerites) {
    if (holerites.isEmpty) return _buildSemDados();

    final sorted = [...holerites]..sort((a, b) => a.mes.compareTo(b.mes));
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: BarChart(_buildBarChart(sorted)),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          _buildDescontosMedia(context, sorted, fmt),
        ],
      ),
    );
  }

  BarChartData _buildBarChart(List<Holerite> sorted) {
    final maxDesconto = sorted
        .map((h) => h.totalDescontos)
        .reduce((a, b) => a > b ? a : b);

    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => const FlLine(
          color: Color(0xFF2A3250),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, meta) {
              const meses = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
              final idx = v.toInt();
              if (idx < 0 || idx >= sorted.length) return const SizedBox();
              return Text(meses[sorted[idx].mes - 1],
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: sorted.asMap().entries.map((entry) {
        final h = entry.value;
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: h.inss,
              color: const Color(0xFFFF5252),
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: h.irrf,
              color: const Color(0xFFFF9800),
              width: 8,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      maxY: maxDesconto * 1.3,
    );
  }

  Widget _buildDescontosMedia(
      BuildContext context, List<Holerite> sorted, NumberFormat fmt) {
    final mediaInss = sorted.fold(0.0, (s, h) => s + h.inss) / sorted.length;
    final mediaIrrf = sorted.fold(0.0, (s, h) => s + h.irrf) / sorted.length;
    final mediaFgts = sorted.fold(0.0, (s, h) => s + h.fgts) / sorted.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Média de Descontos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _descontoItem(context, 'INSS', mediaInss, fmt, const Color(0xFFFF5252)),
        _descontoItem(context, 'IRRF', mediaIrrf, fmt, const Color(0xFFFF9800)),
        _descontoItem(context, 'FGTS (empregador)', mediaFgts, fmt, AppTheme.positive),
      ],
    );
  }

  Widget _descontoItem(BuildContext context, String label, double valor,
      NumberFormat fmt, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12,
                  decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(fmt.format(valor),
              style: TextStyle(color: cor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTabComparativo(
      BuildContext context, HoleriteProvider provider) {
    final porAno = provider.holeritesPorAno;
    if (porAno.isEmpty) return _buildSemDados();

    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final anos = porAno.keys.toList()..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Comparativo Anual',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...anos.map((ano) {
            final holerites = porAno[ano]!;
            final total = holerites.fold(0.0, (s, h) => s + h.salarioLiquido);
            final media = total / holerites.length;
            final maxTotal = anos
                .map((a) => porAno[a]!.fold(0.0, (s, h) => s + h.salarioLiquido))
                .reduce((a, b) => a > b ? a : b);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ano == DateTime.now().year
                      ? AppTheme.primary.withOpacity(0.4)
                      : const Color(0xFF2A3250),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$ano',
                          style: TextStyle(
                              color: ano == DateTime.now().year
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                      Text(
                        fmt.format(total),
                        style: const TextStyle(
                            color: AppTheme.positive,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total / maxTotal,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(
                        ano == DateTime.now().year
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${holerites.length} holerites',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('Média: ${fmt.format(media)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textPrimary)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemDados() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text('Sem dados para o período selecionado',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
