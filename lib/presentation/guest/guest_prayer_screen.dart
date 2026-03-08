import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/routing/app_router.dart';

/// Guest prayer screen with routes that are safe for unauthenticated users.
class GuestPrayerScreen extends StatelessWidget {
  const GuestPrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibadah'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Al-Quran'),
            onTap: () => context.goNamed(AppRoute.guestQuran.name),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('Jadwal Shalat'),
            onTap: () => context.goNamed(AppRoute.guestPrayerTime.name),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Arah Kiblat'),
            onTap: () => context.goNamed(AppRoute.guestQibla.name),
          ),
          ListTile(
            leading: const Icon(Icons.spatial_audio_off),
            title: const Text('Murottal'),
            onTap: () => context.goNamed(AppRoute.guestMurottal.name),
          ),
        ],
      ),
    );
  }
}
