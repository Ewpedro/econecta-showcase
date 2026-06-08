import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/holerite.dart';

class HoleriteService {
  final _client = ApiClient();
  static const _cacheKey = 'holerites_cache', _lastCountKey = 'last_holerite_count';

  Future<List<Holerite>> buscarHolerites() async {
    try {
      final r = await _client.get(ApiConfig.holerites);
      final data = r.data;
      List<dynamic> lista = data is List ? data : (data is Map ? (data['data'] ?? data['holerites'] ?? data['items'] ?? []) : []);
      final holerites = lista.map((e) => Holerite.fromJson(e)).toList();
      return _mesclarComCache(holerites, await _carregarCache());
    } catch (e) {
      final cache = await _carregarCache();
      if (cache.isNotEmpty) return cache;
      throw ApiException('Não foi possível buscar holerites: $e');
    }
  }

  Future<Holerite> baixarPdf(Holerite h, {void Function(int, int)? onProgress}) async {
    if (h.pdfUrl == null) throw ApiException('URL do PDF não disponível');
    final dir = await _getHoleriteDir();
    final path = '${dir.path}/${h.nomeArquivo}';
    await _client.dio.download(h.pdfUrl!, path, onReceiveProgress: onProgress);
    final atualizado = h.copyWith(pdfPath: path, baixado: true, dataBaixado: DateTime.now());
    await _atualizarCache(atualizado);
    return atualizado;
  }

  Future<int> verificarNovos() async {
    try {
      final h = await buscarHolerites();
      final p = await SharedPreferences.getInstance();
      final ultima = p.getInt(_lastCountKey) ?? 0;
      final novos = h.length - ultima;
      await p.setInt(_lastCountKey, h.length);
      return novos > 0 ? novos : 0;
    } catch (_) { return 0; }
  }

  Future<Directory> _getHoleriteDir() async { final b = await getApplicationDocumentsDirectory(); final d = Directory('${b.path}/holerites'); if (!await d.exists()) await d.create(recursive: true); return d; }

  Future<List<Holerite>> _carregarCache() async { final p = await SharedPreferences.getInstance(); final j = p.getString(_cacheKey); if (j == null) return []; try { return (jsonDecode(j) as List).map((e) => Holerite.fromMap(e)).toList(); } catch (_) { return []; } }

  Future<void> _atualizarCache(Holerite h) async { final lista = await _carregarCache(); final i = lista.indexWhere((x) => x.id == h.id); if (i >= 0) lista[i] = h; else lista.add(h); final p = await SharedPreferences.getInstance(); await p.setString(_cacheKey, jsonEncode(lista.map((x) => x.toMap()).toList())); }

  List<Holerite> _mesclarComCache(List<Holerite> remotos, List<Holerite> locais) {
    return remotos.map((r) { final l = locais.firstWhere((x) => x.id == r.id, orElse: () => r); return r.copyWith(pdfPath: l.pdfPath, baixado: l.baixado, dataBaixado: l.dataBaixado); }).toList()..sort((a, b) { if (a.ano != b.ano) return b.ano.compareTo(a.ano); return b.mes.compareTo(a.mes); });
  }
}
