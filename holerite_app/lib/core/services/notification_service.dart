import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'holerite_service.dart';

const _taskName = 'verificar_novos_holerites';
const _notifChannelId = 'holerites_channel';
const _notifChannelName = 'Holerites';

final _plugin = FlutterLocalNotificationsPlugin();

// Chamado pelo WorkManager em background
@pragma('vm:entry-point')
void workManagerCallback() {
  Workmanager().executeTask((task, data) async {
    if (task == _taskName) {
      final novos = await HoleriteService().verificarNovos();
      if (novos > 0) {
        await _mostrarNotificacao(novos);
      }
    }
    return true;
  });
}

class NotificationService {
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _criarCanal();

    // Registra task de background para rodar 1x por dia
    await Workmanager().initialize(workManagerCallback);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(hours: 12),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> mostrarNotificacaoNovoHolerite(int quantidade) {
    return _mostrarNotificacao(quantidade);
  }

  static Future<void> cancelarTudo() => _plugin.cancelAll();
}

Future<void> _criarCanal() async {
  const channel = AndroidNotificationChannel(
    _notifChannelId,
    _notifChannelName,
    description: 'Notificações de novos holerites disponíveis',
    importance: Importance.high,
  );

  await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _mostrarNotificacao(int quantidade) async {
  final texto = quantidade == 1
      ? 'Seu novo holerite está disponível para download!'
      : '$quantidade novos holerites disponíveis!';

  await _plugin.show(
    0,
    '💰 Novo Holerite!',
    texto,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _notifChannelId,
        _notifChannelName,
        channelDescription: 'Novos holerites disponíveis',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1A73E8),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
    ),
  );
}
