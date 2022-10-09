import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:get/get.dart';
import 'package:webview/Routes/Routes.dart';
import 'package:webview/WebView/Login/Login.dart';
import 'package:webview/WebView/WebViewUi.dart';
import 'package:webview/firebase_options.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String dyanmicLink = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      notificationSetting();
      initDynamicLinks();
      configureNotifications();
    });
  }

  final FirebaseMessaging _notifications = FirebaseMessaging.instance;
  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print("link is $dynamicLinkData");
      Get.toNamed(dynamicLinkData.link.queryParameters.values.first);
    }).onError((error) {
      print(error.message);
    });
  }

  configureNotifications() {
    var result = FlutterNotificationChannel.registerNotificationChannel(
      description: 'Your channel description',
      id: 'webview',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Your channel name',
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      allowBubbles: true,
      enableVibration: true,
      enableSound: true,
      showBadge: true,
    );
  }

  void notificationSetting() async {
    NotificationSettings settings = await _notifications.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: Routes.all,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Login());
  }
}
