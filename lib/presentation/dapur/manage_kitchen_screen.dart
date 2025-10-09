import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import '../../routing/app_router.dart';

class ManageKitchenScreen extends HookConsumerWidget {
  const ManageKitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Dapur'),
      ),
      body: ListView(
        children: [
          _buildItemMenu(
            context,
            'Menu Masakan',
            'Kelola menu masakan',
            Icons.food_bank,
            onTap: () {
              context.goNamed(AppRoute.foodMenu.name);
            },
          ),
          const Divider(),
          _buildItemMenu(
            context,
            'Bahan Baku',
            'Kelola bahan baku di dapur',
            Icons.fastfood,
            onTap: () {
              context.goNamed(AppRoute.rawMaterial.name);
            },
          ),
          const Divider(),
          _buildItemMenu(
            context,
            'Belanja Bahan Baku',
            'Belanja bahan baku di dapur',
            Icons.shopping_cart,
            onTap: () {
              context.goNamed(AppRoute.orderRawMaterial.name);
            },
          ),
          const Divider(),
          _buildItemMenu(
            context,
            'Laporan Masak',
            'Laporan proses masak di dapur',
            Icons.report,
            onTap: () {
              context.goNamed(AppRoute.cookingReport.name);
            },
          ),
          const Divider(),
          _buildItemMenu(
            context,
            'Melacak Stok',
            'Melacak pergerakan stok',
            Icons.warehouse,
            onTap: () {
              context.goNamed(AppRoute.trackingStock.name);
            },
          ),
          const Divider(),
          _buildItemMenu(
            context,
            'Stok Opname',
            'Perbaharui stok fisik Anda di aplikasi',
            Icons.numbers,
            onTap: () {
              context.goNamed(AppRoute.stockOpname.name);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildItemMenu(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 32,
        color: context.colorPrimary,
      ),
      title: Text(
        title,
        style: context.titleMediumBold,
      ),
      subtitle: Text(
        description,
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
