import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:just_audio_background/just_audio_background.dart'; // Tetap dikomentari
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/app.dart';

import 'di/providers.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // FIX: Membungkus inisialisasi background dengan try-catch
    try {
        if (Firebase.apps.isEmpty) { 
            await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        }
    } catch (e) {
        print("Background Firebase init error (ignored if 'already exists'): $e");
    }
    
    print("Handling a background message: ${message.messageId}");
}

// Global variables to hold the state before runApp
SharedPreferences? globalPrefs;
AdaptiveThemeMode? globalThemeMode;
ProviderContainer? globalContainer;

Future<void> main() async {
    // 1. Ensure Flutter binding is ready.
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Initialize Firebase (Wajib di awal untuk Crashlytics)
    await _initFirebase();
    
    // Pengecekan pesan background harus diaktifkan setelah Firebase init
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // --- OPTIMASI SPLASH SCREEN (BLOK I/O) ---
    // Semua operasi I/O (disk/network) yang memblokir fungsi main()
    try {
        globalPrefs = await SharedPreferences.getInstance();
    } catch (e) {
        print("Error loading SharedPreferences: $e");
        // Jika gagal, set globalPrefs ke null atau default
    }
    
    globalThemeMode = await AdaptiveTheme.getThemeMode();
    
    // Inisialisasi container dengan nilai yang aman (atau default jika gagal)
    globalContainer = ProviderContainer(
         overrides: [
             sharedPreferencesProvider.overrideWithValue(globalPrefs ?? await SharedPreferences.getInstance()),
         ],
    );
    
    // --- AKHIR BLOK I/O ---
    
    // 3. Pindahkan initServices (plugin notifikasi yang sensitif) ke PostFrameCallback
    // Ini memperbaiki NullPointerException
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _initServices(); 
    });

    runApp(
        UncontrolledProviderScope(
            container: globalContainer!, 
            child: MyApp(
                adaptiveThemeMode: globalThemeMode,
            ),
        ),
    );
}

Future<void> _initFirebase() async {
    // FIX: Pengecekan aman di main thread dengan try-catch untuk menelan error 'already exists'
    if (Firebase.apps.isEmpty) {
        try {
            await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
            );
        } catch (e, stack) {
            // Error ini akan menangani "already exists"
            if (e.toString().contains('already exists')) {
                 print("Firebase already initialized, ignoring second call.");
            } else {
                 FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
            }
        }
    }
    
    // Crashlytics setup
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
    };
}

Future<void> _initServices() async {
    // 1. Channel Creation
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Permission Request
    final notificationsPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (notificationsPlugin != null) {
        try {
            await notificationsPlugin.requestNotificationsPermission(); 
        } catch (e) {
            print("PlatformException during notification permission request: $e");
        }
    }

    // 3. Foreground Message Listener
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
}