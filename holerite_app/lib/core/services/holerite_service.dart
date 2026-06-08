import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/holerite.dart';

class HoleriteService {
  final _client = ApiClient();

  static const _cacheKey = 'holerites_cache';
  static const _lastCountKey = 'last_holerite_count';

  // Busca a lista de holerites da API
  Future<List<Holerite>> buscarHolerites() async {
    try {
      final response = await _client.get(ApiConfig.holerites);
      final data = response.data;

      List<dynamic> lista = [];
      if (data is List) {
        lista = data;
      } else if (data is Map) {
        lista = data['data'] ?? data['holerites'] ?? data['items'] ?? [];
      }

      final holerites = lista.map((e) => Holerite.fromJson(e)).toList();

      // Mescla com dados locais (PDFs já baixados)
      final holeritesSalvos = await _carregarCache();
      return _mesclarComCache(holerites, holeritesSalvos);
    } catch (e) {
      // Se falhar, retorna o cache local
      final cache = await _carregarCache();
      if (cache.isNotEmpty) return cache;
      throw ApiException('Não foi possível buscar holerites: $e');
    }
  }

  // Baixa o PDF de um holerite
  Future<Holerite> baixarPdf(
    Holerite holerite, {
    void Function(int, int)? onProgress,
  }) async {
    if (holerite.pdfUrl == null) {
      throw ApiException('URL do PDF não disponível');
    }

    final dir = await _getHoleriteDir();
    final filePath = '${dir.path}/${holerite.nomeArquivo}';

    await _client.dio.download(
      holerite.pdfUrl!,
      filePath,
      onReceiveProgress: onProgress,
    );

    final atualizado = holerite.copyWith(
      pdfPath: filePath,
      baixado: true,
      dataBaixado: DateTime.now(),
    );

    await _atualizarCache(atualizado);
    return atualizado;
  }

  // Verifica se há novos holerites (para background sync)
  Future<int> verificarNovos() async {
    try {
      final holerites = await buscarHolerites();
      final prefs = await SharedPreferences.getInstance();
      final ultimaQtd = prefs.getInt(_lastCountKey) ?? 0;
      final novos = holerites.length - ultimaQtd;
      await prefs.setInt(_lastCountKey, holerites.length);
      return novos > 0 ? novos : 0;
    } catch (_) {
      return 0;
    }
  }

  // Verifica se PDF já existe localmente
  Future<bool> isPdfDisponivel(Holerite holerite) async {
    if (holerite.pdfPath == null) return false;
    return File(holerite.pdfPath!).exists();
  }

  Future<Directory> _getHoleriteDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/holerites');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<Holerite>> _carregarCache() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cacheKey);
    if (json == null) return [];
    try {
      final lista = jsonDecode(json) as List;
      return lista.map((e) => Holerite.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _atualizarCache(Holerite holerite) async {
    final lista = await _carregarCache();
    final idx = lista.indexWhere((h) => h.id == holerite.id);
    if (idx >= 0) {
      lista[idx] = holerite;
    } else {
      lista.add(holerite);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(lista.map((h) => h.toMap()).toList()));
  }

  List<Holerite> _mesclarComCache(
    List<Holerite> remotos,
    List<Holerite> locais,
  ) {
    return remotos.map((remoto) {
      final local = locais.firstWhere(
        (l) => l.id == remoto.id,
        orElse: () => remoto,
      );
      return remoto.copyWith(
        pdfPath: local.pdfPath,
        baixado: local.baixado,
        dataBaixado: local.dataBaixado,
      );
    }).toList()
      ..sort((a, b) {
        if (a.ano != b.ano) return b.ano.compareTo(a.ano);
        return b.mes.compareTo(a.mes);
      });
  }
}
