import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sunspark/screens/auth/landing_screen.dart';
import 'package:sunspark/screens/mewhome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'sunspark-efc9c',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<void> notificationSetup() async {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        soundSource: 'resource://raw/res_morph_power_rangers',
        channelKey: 'sound_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        importance: NotificationImportance.High,
        playSound: true,
        // defaultRingtoneType: DefaultRingtoneType.Ringtone,
      ),
      NotificationChannel(
        soundSource: 'resource://raw/res_morph_power_rangers',
        channelKey: 'sound_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        importance: NotificationImportance.High,
        playSound: true,
        // defaultRingtoneType: DefaultRingtoneType.Ringtone,
      )
    ], channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: 'sound_channel',
          channelGroupName: 'Basic notifications'),
    ]);
  }

  Future<void> onForegroundMessage() async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (message.notification != null) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              criticalAlert: true,
              id: Random().nextInt(9999),
              channelKey: 'sound_channel',
              title: '${message.notification!.title}',
              body: '${message.notification!.body}',
              notificationLayout: NotificationLayout.Inbox,
            ),
          );
          AudioPlayer audioPlayer = AudioPlayer();
          audioPlayer.play(AssetSource("audio/alert.mp3"));
          // AssetsAudioPlayer.newPlayer().open(
          //   Audio("assets/audio/alert.mp3"),
          //   autoStart: true,
          // );
        }
      },
    );
  }

  Future<bool> checkNotificationPermission() async {
    var res = await messaging.requestPermission();
    if (res.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else {
      return false;
    }
  }

  initPermission() async {
    if (await checkNotificationPermission() == true) {
      await notificationSetup();
      await onBackgroundMessage();
      await onForegroundMessage();
    }
  }

  @override
  void initState() {
    initPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? LandingScreen()
          : NewHomeScreen(inUser: false),
    );
  }
}

Future<void> onBackgroundMessage() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        criticalAlert: true,
        id: Random().nextInt(9999),
        channelKey: 'sound_channel',
        title: '${message.notification!.title}',
        body: '${message.notification!.body}',
        notificationLayout: NotificationLayout.Inbox,
      ),
    );
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource("audio/alert.mp3"));
  }
}
