import 'package:flutter/foundation.dart';
import '../models/holerite.dart';
import '../services/auth_service.dart';
import '../services/holerite_service.dart';

enum AppState { initial, loading, loaded, error }

class HoleriteProvider extends ChangeNotifier {
  final _holeriteService = HoleriteService();
  final _authService = AuthService();

  AppState _state = AppState.initial;
  List<Holerite> _holerites = [];
  UserInfo? _user;
  String? _erro;
  String? _downloadingId;

  AppState get state => _state;
  List<Holerite> get holerites => _holerites;
  UserInfo? get user => _user;
  String? get erro => _erro;
  String? get downloadingId => _downloadingId;
  bool get isLoading => _state == AppState.loading;

  // Estatísticas calculadas
  double get mediaSalarialLiquido {
    if (_holerites.isEmpty) return 0;
    return _holerites.map((h) => h.salarioLiquido).reduce((a, b) => a + b) /
        _holerites.length;
  }

  double get totalRecebidoAno {
    final anoAtual = DateTime.now().year;
    return _holerites
        .where((h) => h.ano == anoAtual)
        .fold(0.0, (sum, h) => sum + h.salarioLiquido);
  }

  Holerite? get ultimoHolerite =>
      _holerites.isNotEmpty ? _holerites.first : null;

  List<Holerite> get holertiesAnoAtual {
    final anoAtual = DateTime.now().year;
    return _holerites.where((h) => h.ano == anoAtual).toList();
  }

  Future<void> inicializar() async {
    _user = await _authService.getUserInfo();
    notifyListeners();
    await carregarHolerites();
  }

  Future<void> carregarHolerites() async {
    _state = AppState.loading;
    _erro = null;
    notifyListeners();

    try {
      _holerites = await _holeriteService.buscarHolerites();
      _state = AppState.loaded;
    } catch (e) {
      _erro = e.toString();
      _state = AppState.error;
    }

    notifyListeners();
  }

  Future<bool> baixarPdf(Holerite holerite) async {
    _downloadingId = holerite.id;
    notifyListeners();

    try {
      final atualizado = await _holeriteService.baixarPdf(holerite);
      final idx = _holerites.indexWhere((h) => h.id == holerite.id);
      if (idx >= 0) _holerites[idx] = atualizado;
      _downloadingId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _downloadingId = null;
      notifyListeners();
      return false;
    }
  }

  Map<int, List<Holerite>> get holeritesPorAno {
    final map = <int, List<Holerite>>{};
    for (final h in _holerites) {
      map.putIfAbsent(h.ano, () => []).add(h);
    }
    return map;
  }
}
