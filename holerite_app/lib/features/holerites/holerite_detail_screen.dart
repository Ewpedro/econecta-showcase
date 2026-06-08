import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/holerite.dart';
import '../../core/services/holerite_provider.dart';
import '../../core/theme/app_theme.dart';

class HoleriteDetailScreen extends StatefulWidget {
  final Holerite holerite;

  const HoleriteDetailScreen({super.key, required this.holerite});

  @override
  State<HoleriteDetailScreen> createState() => _HoleriteDetailScreenState();
}

class _HoleriteDetailScreenState extends State<HoleriteDetailScreen> {
  bool _mostrandoPdf = false;
  int _totalPaginas = 0;
  int _paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final h = widget.holerite;

    return Scaffold(
      appBar: AppBar(
        title: Text(h.competencia),
        backgroundColor: AppTheme.background,
        actions: [
          if (h.baixado && h.pdfPath != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _compartilhar(h),
            ),
        ],
      ),
      body: h.baixado && h.pdfPath != null && _mostrandoPdf
          ? _buildPdfViewer(h)
          : _buildDetalhes(context, h, fmt),
      floatingActionButton: _buildFab(context, h),
    );
  }

  Widget _buildDetalhes(
      BuildContext context, Holerite h, NumberFormat fmt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card principal
          _buildCardValores(context, h, fmt),
          const SizedBox(height: 20),

          // Proventos
          if (h.outrosProventos.isNotEmpty) ...[
            _buildSecaoItens(
                context, 'Proventos', h.outrosProventos
                    .map((p) => _ItemValor(p.descricao, p.valor, true))
                    .toList(), fmt),
            const SizedBox(height: 16),
          ],

          // Descontos
          _buildSecaoDescontos(context, h, fmt),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCardValores(
      BuildContext context, Holerite h, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Salário Líquido',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(h.salarioLiquido),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  'Bruto',
                  fmt.format(h.salarioBruto),
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoChip(
                  'Descontos',
                  fmt.format(h.totalDescontos),
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  color: cor, fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSecaoDescontos(
      BuildContext context, Holerite h, NumberFormat fmt) {
    final itens = [
      if (h.inss > 0) _ItemValor('INSS', h.inss, false),
      if (h.irrf > 0) _ItemValor('IRRF', h.irrf, false),
      ...h.outrosDescontos.map((d) => _ItemValor(d.descricao, d.valor, false)),
    ];
    if (h.fgts > 0) itens.add(_ItemValor('FGTS (empregador)', h.fgts, true));

    return _buildSecaoItens(context, 'Descontos', itens, fmt);
  }

  Widget _buildSecaoItens(
    BuildContext context,
    String titulo,
    List<_ItemValor> itens,
    NumberFormat fmt,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(titulo,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(color: Color(0xFF2A3250), height: 1),
          ...itens.map(
            (item) => Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.descricao,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      Text(
                        fmt.format(item.valor),
                        style: TextStyle(
                          color: item.isProvento
                              ? AppTheme.positive
                              : AppTheme.negative,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (itens.last != item)
                  const Divider(
                      color: Color(0xFF2A3250), height: 1, indent: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(Holerite h) {
    return Stack(
      children: [
        PDFView(
          filePath: h.pdfPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onPageChanged: (page, total) {
            setState(() {
              _paginaAtual = page ?? 0;
              _totalPaginas = total ?? 0;
            });
          },
        ),
        if (_totalPaginas > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Página ${_paginaAtual + 1} de $_totalPaginas',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, Holerite h) {
    if (h.baixado && h.pdfPath != null) {
      return FloatingActionButton.extended(
        backgroundColor: _mostrandoPdf ? AppTheme.surfaceVariant : AppTheme.primary,
        onPressed: () => setState(() => _mostrandoPdf = !_mostrandoPdf),
        icon: Icon(_mostrandoPdf ? Icons.info_outline : Icons.picture_as_pdf),
        label: Text(_mostrandoPdf ? 'Ver Detalhes' : 'Ver PDF'),
      );
    }

    return Consumer<HoleriteProvider>(
      builder: (context, provider, _) {
        final downloading = provider.downloadingId == h.id;
        return FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          onPressed: downloading
              ? null
              : () async {
                  final ok = await provider.baixarPdf(h);
                  if (ok && mounted) {
                    setState(() => _mostrandoPdf = true);
                  }
                },
          icon: downloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download_rounded),
          label: Text(downloading ? 'Baixando...' : 'Baixar PDF'),
        );
      },
    );
  }

  void _compartilhar(Holerite h) {
    Share.shareXFiles(
      [XFile(h.pdfPath!)],
      subject: 'Holerite ${h.competencia}',
    );
  }
}

class _ItemValor {
  final String descricao;
  final double valor;
  final bool isProvento;

  _ItemValor(this.descricao, this.valor, this.isProvento);
}
