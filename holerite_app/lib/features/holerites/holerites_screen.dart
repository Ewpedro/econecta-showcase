import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/holerite.dart';
import '../../core/services/holerite_provider.dart';
import '../../core/theme/app_theme.dart';
import 'holerite_detail_screen.dart';

class HoleritesScreen extends StatelessWidget {
  const HoleritesScreen({super.key});

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
                  _buildAppBar(context),
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    )
                  else if (provider.holerites.isEmpty)
                    _buildVazio(context)
                  else
                    _buildLista(context, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.background,
      title: const Text('Holerites'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () {},
          tooltip: 'Filtrar',
        ),
      ],
    );
  }

  Widget _buildVazio(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum holerite encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, HoleriteProvider provider) {
    final porAno = provider.holeritesPorAno;
    final anos = porAno.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          int counter = 0;
          for (final ano in anos) {
            if (index == counter) {
              return _buildAnoHeader(context, ano, porAno[ano]!);
            }
            counter++;
            final holerites = porAno[ano]!;
            for (int i = 0; i < holerites.length; i++) {
              if (index == counter) {
                return _buildCard(context, holerites[i], provider, counter)
                    .animate()
                    .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                    .slideX(begin: 0.05);
              }
              counter++;
            }
          }
          return null;
        },
        childCount: anos.fold(0, (sum, ano) => sum + 1 + porAno[ano]!.length),
      ),
    );
  }

  Widget _buildAnoHeader(
      BuildContext context, int ano, List<Holerite> holerites) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final totalAnual = holerites.fold(0.0, (s, h) => s + h.salarioLiquido);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$ano',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            'Total: ${fmt.format(totalAnual)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.positive,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Holerite holerite,
    HoleriteProvider provider,
    int animIndex,
  ) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDownloading = provider.downloadingId == holerite.id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HoleriteDetailScreen(holerite: holerite),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: holerite.baixado
                  ? AppTheme.positive.withOpacity(0.3)
                  : const Color(0xFF2A3250),
            ),
          ),
          child: Row(
            children: [
              // Ícone do mês
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _mesAbreviado(holerite.mes),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${holerite.ano}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holerite.competencia,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Líquido: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                        Text(
                          fmt.format(holerite.salarioLiquido),
                          style: const TextStyle(
                            color: AppTheme.positive,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (holerite.baixado)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.positive, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'PDF salvo',
                            style: TextStyle(
                              color: AppTheme.positive,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Botão download
              _buildDownloadButton(context, holerite, provider, isDownloading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    Holerite holerite,
    HoleriteProvider provider,
    bool isDownloading,
  ) {
    if (isDownloading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.primary,
        ),
      );
    }

    return IconButton(
      icon: Icon(
        holerite.baixado
            ? Icons.picture_as_pdf_rounded
            : Icons.download_rounded,
        color: holerite.baixado ? AppTheme.positive : AppTheme.primary,
      ),
      onPressed: () async {
        if (holerite.baixado && holerite.pdfPath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HoleriteDetailScreen(holerite: holerite),
            ),
          );
        } else {
          final ok = await provider.baixarPdf(holerite);
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao baixar o PDF'),
                backgroundColor: AppTheme.negative,
              ),
            );
          }
        }
      },
    );
  }

  String _mesAbreviado(int mes) {
    const meses = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
    ];
    return meses[mes - 1];
  }
}
