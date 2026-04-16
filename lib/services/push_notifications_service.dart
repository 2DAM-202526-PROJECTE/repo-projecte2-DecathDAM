import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Aquesta funció s'ha de posar a l'arrel de l'arxiu (no dins la classe) per poder escoltar
// notificacions mentre l'app està tancada o de fons.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nota: si vols fer servir Firebase aquí, cal assegurar-se que Firebase s'inicialitza, però
  // generalment per mostrar notificacions al 'system tray' el mateix FCM ho fa automàticament
  // quan l'app està en segon pla.
  debugPrint("S'ha rebut un missatge en segon pla (background): ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // 1. Demanar permisos de notificacions a l'usuari (Crucial a Android 13+ i iOS)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('Estat dels permisos de notificació: ${settings.authorizationStatus}');

      // 2. Definir què passa quan rebem notificacions i l'app està en segon pla
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Obtenir el token FCM del dispositiu
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("*************************************************");
        debugPrint("FCM DEVICE TOKEN: $token");
        debugPrint("Utilitza aquest token per enviar notificacions de prova des de la consola Firebase.");
        debugPrint("*************************************************");
      }

      // 4. Configurar notificacions locals (perquè es vegin d'alta prioritat al primer pla)
      await _setupLocalNotifications();

      // 5. Escoltar i mostrar notificacions quan l'app està en primer pla (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Missatge FCM rebut en primer pla: ${message.notification?.title}');

        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });
    } catch (e) {
      debugPrint("Error inicialitzant Push Notifications: $e");
    }
  }

  static Future<void> _setupLocalNotifications() async {
    
    // Utilitza la icona per defecte de l'aplicació per les notificacions
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,

      
    );

    await _localNotificationsPlugin.initialize(settings: initializationSettings);

    // Creació obligatòria del canal per a Android 8.0 o superior (per alta prioritat)
    if (defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'decathdam_main_channel', // Id del canal
        'Notificacions Principals', // Nom
        description: 'Aquest canal s\'usa pel gruix de notificacions de l\'app.', 
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'decathdam_main_channel',
            'Notificacions Principals',
            channelDescription: 'Aquest canal s\'usa pel gruix de notificacions de l\'app.',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'launcher_icon',
          ),
        ),
      );
    }
  }
}
