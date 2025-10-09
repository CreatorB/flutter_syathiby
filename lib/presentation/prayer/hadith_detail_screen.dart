import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/generated/fonts.gen.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'hadith_controller.dart';

class HadithDetail {
  final String bookId;
  final int hadithNumber;

  HadithDetail(this.bookId, this.hadithNumber);
}

class HadithDetailScreen extends HookConsumerWidget {
  final HadithDetail hadithDetail;

  const HadithDetailScreen({super.key, required this.hadithDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchHadithDetail = ref.watch(
      fetchHadithDetailProvider(
        bookId: hadithDetail.bookId,
        hadithNumber: hadithDetail.hadithNumber,
      ),
    );
    final book = fetchHadithDetail.valueOrNull?.data;
    final hadith = fetchHadithDetail.valueOrNull?.data.contents;
    final templateShare =
        '${hadith?.arab}\n\n${hadith?.id}\n\n(${book?.name}: ${hadith?.number})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian Hadits'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Skeletonizer(
        enabled: fetchHadithDetail.isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      'Hadits No. ${hadith?.number ?? '${hadithDetail.hadithNumber}'}',
                      style: context.titleLargeBold?.copyWith(
                        color: context.colorPrimary,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: context.colorPrimary,
                      ),
                      onPressed: () {
                        Share.share(templateShare);
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.copy,
                        color: context.colorPrimary,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: templateShare));
                        context.showSuccessMessage('Berhasil menyalin hadits');
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    hadith?.arab ?? 'Tidak ditemukan',
                    textAlign: TextAlign.end,
                    style: context.displaySmall?.copyWith(
                      fontFamily: FontFamily.uthmanic,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    hadith?.id ?? '',
                    style: context.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
