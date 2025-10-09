import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/generated/l10n.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';

class MyApp extends HookConsumerWidget {
  final AdaptiveThemeMode? adaptiveThemeMode;

  const MyApp({super.key, this.adaptiveThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    useEffect(() {
      setupInteractedMessage(ref);
      return null;
    }, []);
    return AdaptiveTheme(
      light: FlexThemeData.light(
        useMaterial3: true,
        scheme: FlexScheme.greenM3,
        transparentStatusBar: true,
      ),
      dark: FlexThemeData.dark(
        useMaterial3: true,
        scheme: FlexScheme.greenM3,
        transparentStatusBar: true,
      ),
      initial: adaptiveThemeMode ?? AdaptiveThemeMode.light,
      builder: (light, dark) => MaterialApp.router(
        title: AppConstant.appName,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        routerConfig: goRouter,
        theme: light,
        darkTheme: dark,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage(WidgetRef ref) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await ref.watch(firebaseMessagingProvider).getInitialMessage();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage, channel, flutterLocalNotificationsPlugin);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) {
        _handleMessage(event, channel, flutterLocalNotificationsPlugin);
      },
    );
  }

  void _handleMessage(
    RemoteMessage message,
    AndroidNotificationChannel channel,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) {
    // if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(context, '/chat',
    //     arguments: ChatArguments(message),
    //   );
    // }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
            // other properties...
          ),
        ),
      );
    }
  }
}