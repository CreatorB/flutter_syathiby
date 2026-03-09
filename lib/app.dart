import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/generated/l10n.dart';
import 'package:syathiby/res/colors.dart';
import 'package:syathiby/res/environment_config.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';

class MyApp extends HookConsumerWidget {
  final AdaptiveThemeMode? adaptiveThemeMode;

  const MyApp({super.key, this.adaptiveThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final isLocalEnv = EnvironmentConfig.isLocalEnvironment;
    final environmentLabel = EnvironmentConfig.environmentLabel;
    final environmentColor = isLocalEnv ? Colors.red : Colors.green;
    useEffect(() {
      setupInteractedMessage(ref);
      return null;
    }, []);
    return AdaptiveTheme(
      light: _buildLightTheme(),
      dark: _buildDarkTheme(),
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
        builder: (context, child) {
          final appChild = child ?? const SizedBox.shrink();
          // Show banner only for LOCAL environment (development)
          // For PROD, no banner (clean production UI)
          if (!isLocalEnv) {
            return appChild;
          }
          return Banner(
            message: environmentLabel,
            location: BannerLocation.topEnd,
            color: environmentColor,
            child: appChild,
          );
        },
      ),
    );
  }

  /// Build light theme with strong gradient and 3D effects
  ThemeData _buildLightTheme() {
    // Gradient colors from base palette
    const primaryColor = Color(0xFF26774e);  // Primary
    const darkColor = Color(0xFF19633f);     // Dark
    const lightColor = Color(0xFF82aa68);    // Light
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      
      // AppBar with gradient effect (simulated with primary)
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 8,
        shadowColor: darkColor.withOpacity(0.5),
        scrolledUnderElevation: 12,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Scaffold with light gradient background
      scaffoldBackgroundColor: const Color(0xFFF5F9F7), // Subtle green tint
      
      // Card with strong 3D elevation and shadow
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: darkColor.withOpacity(0.3),
        color: Colors.white,
        surfaceTintColor: lightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      
      // Navigation bar with gradient accent
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 12,
        shadowColor: darkColor.withOpacity(0.2),
        indicatorColor: lightColor,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: darkColor);
          }
          return IconThemeData(color: Colors.grey[600]);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      
      // Bottom sheet with 3D shadow
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        elevation: 16,
        shadowColor: darkColor.withOpacity(0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      
      // Dialog with strong 3D effect
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shadowColor: darkColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      
      // FAB with strong gradient colors and 3D shadow
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 12,
        highlightElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration with gradient focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8F5E9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2.5),
        ),
      ),
      
      // Elevated button with strong gradient and 3D effect
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: darkColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Outlined button with gradient border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      
      // List tile with gradient accent
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: lightColor.withOpacity(0.3),
        selectedColor: darkColor,
      ),
      
      // Chip with gradient styling
      chipTheme: ChipThemeData(
        backgroundColor: lightColor.withOpacity(0.2),
        selectedColor: lightColor,
        secondarySelectedColor: primaryColor,
        labelStyle: const TextStyle(color: darkColor),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // TabBar with white text for better contrast
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: primaryColor,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build dark theme with strong gradient and 3D effects
  ThemeData _buildDarkTheme() {
    // Gradient colors from base palette
    const primaryColor = Color(0xFF26774e);  // Primary
    const darkColor = Color(0xFF19633f);     // Dark
    const lightColor = Color(0xFF82aa68);    // Light
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      
      // AppBar with gradient effect
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.6),
        scrolledUnderElevation: 12,
        backgroundColor: darkColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Scaffold with dark gradient background
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // Card with strong 3D elevation and shadow
      cardTheme: CardThemeData(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.6),
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      
      // Navigation bar with gradient accent
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.8),
        indicatorColor: primaryColor,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return IconThemeData(color: Colors.grey[400]);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      
      // Bottom sheet with 3D shadow
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        modalBackgroundColor: const Color(0xFF1E1E1E),
        elevation: 16,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      
      // Dialog with strong 3D effect
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 16,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      
      // FAB with strong gradient colors and 3D shadow
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColor,
        foregroundColor: darkColor,
        elevation: 12,
        highlightElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration with gradient focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightColor, width: 2.5),
        ),
      ),
      
      // Elevated button with strong gradient and 3D effect
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColor,
          foregroundColor: darkColor,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Outlined button with gradient border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColor,
          side: const BorderSide(color: lightColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      
      // List tile with gradient accent
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: primaryColor.withOpacity(0.3),
        selectedColor: lightColor,
      ),
      
      // Chip with gradient styling
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.2),
        selectedColor: primaryColor,
        secondarySelectedColor: lightColor,
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: darkColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // TabBar with white text for better contrast
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: lightColor,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage(WidgetRef ref) async {
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase not initialized yet; skip interacted-message setup.');
      return;
    }

    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await ref.read(firebaseMessagingProvider).getInitialMessage();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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