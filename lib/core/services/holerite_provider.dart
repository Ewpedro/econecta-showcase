import 'package:flutter/foundation.dart';
import '../models/holerite.dart';
import '../services/auth_service.dart';
import '../services/holerite_service.dart';

enum AppState { initial, loading, loaded, error }

class HoleriteProvider extends ChangeNotifier {
  final _hs = HoleriteService();
  final _as = AuthService();
  AppState _state = AppState.initial;
  List<Holerite> _holerites = [];
  UserInfo? _user;
  String? _erro, _downloadingId;

  AppState get state => _state;
  List<Holerite> get holerites => _holerites;
  UserInfo? get user => _user;
  String? get erro => _erro;
  String? get downloadingId => _downloadingId;
  bool get isLoading => _state == AppState.loading;
  double get mediaSalarialLiquido { if (_holerites.isEmpty) return 0; return _holerites.map((h) => h.salarioLiquido).reduce((a, b) => a + b) / _holerites.length; }
  double get totalRecebidoAno { final a = DateTime.now().year; return _holerites.where((h) => h.ano == a).fold(0.0, (s, h) => s + h.salarioLiquido); }
  Holerite? get ultimoHolerite => _holerites.isNotEmpty ? _holerites.first : null;
  List<Holerite> get holertiesAnoAtual { final a = DateTime.now().year; return _holerites.where((h) => h.ano == a).toList(); }
  Map<int, List<Holerite>> get holeritesPorAno { final m = <int, List<Holerite>>{}; for (final h in _holerites) m.putIfAbsent(h.ano, () => []).add(h); return m; }

  Future<void> inicializar() async { _user = await _as.getUserInfo(); notifyListeners(); await carregarHolerites(); }

  Future<void> carregarHolerites() async {
    _state = AppState.loading; _erro = null; notifyListeners();
    try { _holerites = await _hs.buscarHolerites(); _state = AppState.loaded; } catch (e) { _erro = e.toString(); _state = AppState.error; }
    notifyListeners();
  }

  Future<bool> baixarPdf(Holerite h) async {
    _downloadingId = h.id; notifyListeners();
    try { final a = await _hs.baixarPdf(h); final i = _holerites.indexWhere((x) => x.id == h.id); if (i >= 0) _holerites[i] = a; _downloadingId = null; notifyListeners(); return true; }
    catch (e) { _downloadingId = null; notifyListeners(); return false; }
  }
}
