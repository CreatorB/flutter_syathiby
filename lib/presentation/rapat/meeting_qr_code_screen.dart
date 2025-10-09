import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/meeting/meeting.dart';

class MeetingQrCodeScreen extends HookConsumerWidget {
  final Rapat? meeting;

  const MeetingQrCodeScreen({super.key, this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshotController = useMemoized(() => ScreenshotController());

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Presensi QR Code'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final result = await screenshotController.capture();
                  if (result == null) {
                    context.showErrorMessage('Gagal menyimpan screenshot');
                    return;
                  }
                  // Save the image temporarily in the device's temp directory
                  final tempDir = await getTemporaryDirectory();
                  final file =
                  await File('${tempDir.path}/screenshot.png').create();
                  await file.writeAsBytes(result);

                  await Share.shareXFiles(
                    [
                      XFile(
                        file.path,
                        name: 'QR Code ${meeting?.nameMeeting}',
                        mimeType: 'image/png',
                      ),
                    ],
                    text: 'Rekap Absensi Bulanan',
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal membagikan screenshot');
                }
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: () async {
                try {
                  final result = await screenshotController.capture();
                  if (result == null) {
                    context.showErrorMessage('Gagal menyimpan screenshot');
                    return;
                  }
                  await FileSaver.instance.saveAs(
                    bytes: result,
                    ext: 'jpg',
                    name: 'QR Code ${meeting?.nameMeeting}',
                    mimeType: MimeType.jpeg,
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal menyimpan screenshot');
                }
              },
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: QrImageView(data: '${meeting?.idMeeting}'),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Absensi ${meeting?.nameMeeting}',
                style: context.titleMediumBold,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Silahkan scan kode QR diatas untuk presensi rapat',
                style: context.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
