import 'dart:async';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/app.dart';

import 'di/providers.dart';
import 'firebase_options.dart';
import 'utils/web_splash_utility.dart';

// FIX: Removed top-level FlutterLocalNotificationsPlugin instantiation to prevent Safari crash.
// The plugin is now instantiated lazily inside _initServices().

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
        if (Firebase.apps.isEmpty) { 
            await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        }
    } catch (e) {
        // Silently fail in production
    }
}

// Global variables to hold the state before runApp
SharedPreferences? globalPrefs;
AdaptiveThemeMode? globalThemeMode;
ProviderContainer? globalContainer;

Future<void> main() async {
    // Setup global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
            print('═══ Flutter Error ═══');
            print('Exception: ${details.exception}');
            print('Stack: ${details.stack}');
        }
    };

    runZonedGuarded(() async {
        // 1. Ensure Flutter binding is ready.
        WidgetsFlutterBinding.ensureInitialized();

        // 2. Initialize Firebase (skip on web for Safari compatibility)
        if (!kIsWeb) {
            await _initFirebase();
        }

    // On Web, background messages are handled by the service worker.
    // On Android/iOS, we register the handler.
    if (!kIsWeb) {
        try {
            FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        } catch (e) {
            print("Error registering background handler: $e");
        }
    }

    // --- OPTIMASI SPLASH SCREEN (PARALLEL I/O) ---
    try {
        final results = await Future.wait<dynamic>([
            SharedPreferences.getInstance()
                .timeout(Duration(seconds: kIsWeb ? 2 : 5), onTimeout: () {
                    debugPrint("SharedPreferences timeout, continuing...");
                    return SharedPreferences.getInstance(); // Still potentially problematic, but let's increase timeout first
                }),
            AdaptiveTheme.getThemeMode()
                .timeout(Duration(seconds: kIsWeb ? 1 : 3), onTimeout: () {
                    debugPrint("AdaptiveTheme timeout, using light mode");
                    return AdaptiveThemeMode.light;
                }),
        ]).timeout(
            Duration(seconds: kIsWeb ? 3 : 7),
            onTimeout: () {
                debugPrint("Overall initialization timeout");
                return [null, AdaptiveThemeMode.light];
            },
        );

        globalPrefs = results[0] as SharedPreferences?;
        globalThemeMode = results[1] as AdaptiveThemeMode?;
    } catch (e) {
        debugPrint("Error during initialization: $e");
        globalPrefs = null;
        globalThemeMode = AdaptiveThemeMode.light;
    }
    // Call removal earlier - as soon as we have enough state to build the app (REMOVED)

    try {
        globalContainer = ProviderContainer(
             overrides: [
                 sharedPreferencesProvider.overrideWithValue(
                     globalPrefs ?? await SharedPreferences.getInstance()
                 ),
             ],
        );
    } catch (e) {
        debugPrint("Error creating ProviderContainer: $e");
        globalContainer = ProviderContainer();
    }
    // --- AKHIR BLOK I/O ---

    // 3. Initialize services in PostFrameCallback to avoid blocking startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _initServices();
    });

        if (kDebugMode) print('Running app...');
        runApp(
            UncontrolledProviderScope(
                container: globalContainer!,
                child: MyApp(
                    adaptiveThemeMode: globalThemeMode ?? AdaptiveThemeMode.light,
                ),
            ),
        );
        WebSplashUtility.remove(); 
        if (kDebugMode) print('App started successfully');
    }, (error, stack) {
        // Catch any uncaught errors
        print('═══ Uncaught Error ═══');
        print('Error: $error');
        print('Stack: $stack');
    });
}

Future<void> _initFirebase() async {
    if (Firebase.apps.isEmpty) {
        try {
            await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
            ).timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                    debugPrint("Firebase initialization timeout");
                    throw TimeoutException('Firebase init timeout');
                },
            );
        } catch (e) {
            if (e.toString().contains('already exists')) {
                debugPrint("Firebase already initialized.");
            } else {
                debugPrint("Firebase init error: $e");
                // On web (especially Safari), Firebase might fail to initialize
                // Continue app execution even if Firebase fails
                if (kIsWeb) {
                    debugPrint("Continuing without Firebase on web");
                    return;
                }
            }
        }
    }

    try {
        if (Firebase.apps.isNotEmpty && !kIsWeb) {
            // Crashlytics is not available on web
            FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
            PlatformDispatcher.instance.onError = (error, stack) {
                FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
                return true;
            };
        }
    } catch (e) {
        debugPrint("Crashlytics setup error: $e");
    }
}

Future<void> _initServices() async {
    // Skip notification services on web
    if (kIsWeb) {
        debugPrint("Skipping notification services on web platform");
        return;
    }

    // FIX: Instantiate plugin LOCALLY to avoid global config crashes
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Ensure plugin has valid Android context before channel/permission calls.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
    );

    // 1. Channel Creation
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Foreground Message Listener
    try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            RemoteNotification? notification = message.notification;
            AndroidNotification? android = message.notification?.android;
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
                            icon: '@mipmap/ic_launcher',
                        ),
                    ),
                );
            }
        });
    } catch (e) {
        debugPrint("Firebase Messaging error: $e");
    }
}