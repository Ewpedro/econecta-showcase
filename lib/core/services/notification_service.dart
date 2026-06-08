import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'holerite_service.dart';

const _taskName = 'verificar_novos_holerites';
const _notifChannelId = 'holerites_channel';
const _notifChannelName = 'Holerites';
final _plugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void workManagerCallback() {
  Workmanager().executeTask((task, data) async {
    if (task == _taskName) { final n = await HoleriteService().verificarNovos(); if (n > 0) await _notify(n); }
    return true;
  });
}

class NotificationService {
  static Future<void> init() async {
    await _plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true)));
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(const AndroidNotificationChannel(_notifChannelId, _notifChannelName, description: 'Novos holerites', importance: Importance.high));
    await Workmanager().initialize(workManagerCallback);
    await Workmanager().registerPeriodicTask(_taskName, _taskName, frequency: const Duration(hours: 12), constraints: Constraints(networkType: NetworkType.connected), existingWorkPolicy: ExistingWorkPolicy.keep);
  }
  static Future<void> cancelarTudo() => _plugin.cancelAll();
}

Future<void> _notify(int n) => _plugin.show(0, '💰 Novo Holerite!', n == 1 ? 'Seu novo holerite está disponível!' : '$n novos holerites disponíveis!', const NotificationDetails(android: AndroidNotificationDetails(_notifChannelId, _notifChannelName, importance: Importance.high, priority: Priority.high, color: Color(0xFF1A73E8))));
