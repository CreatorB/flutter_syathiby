import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ScanBarcodeScreen extends HookConsumerWidget {
  final bool isSingleCapture;
  final Function(String text) onCapture;

  const ScanBarcodeScreen({
    super.key,
    required this.isSingleCapture,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: AiBarcodeScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (BarcodeCapture barcodeCapture) {
          final data = barcodeCapture.barcodes.lastOrNull?.rawValue;
          debugPrint('CHECK DATA : $data');
          if(data == null) return;
          onCapture(data);
          if(isSingleCapture) {
            context.pop();
            return;
          }
        },
        hideSheetDragHandler: true,
        hideGalleryButton: true,
        hideGalleryIcon: true,
        hideSheetTitle: true,
      ),
    );
  }
}
