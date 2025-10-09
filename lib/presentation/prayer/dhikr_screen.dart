import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/generated/fonts.gen.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'dhikr_controller.dart';

enum DhikrType { morning, evening }

class DhikrScreen extends HookConsumerWidget {
  final DhikrType type;

  const DhikrScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == DhikrType.morning ? 'Pagi' : 'Petang';
    final fetchDhikr = ref.watch(
      type == DhikrType.morning
          ? fetchMorningDhikrProvider
          : fetchEveningDhikrProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Dzikir $title'),
      ),
      body: Skeletonizer(
        enabled: fetchDhikr.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            type == DhikrType.morning
                ? fetchMorningDhikrProvider.future
                : fetchEveningDhikrProvider.future,
          ),
          child: ListView.builder(
            itemCount: fetchDhikr.valueOrNull?.length ?? 10,
            itemBuilder: (context, index) {
              final dhikr = fetchDhikr.valueOrNull?.elementAtOrNull(index);
              final templateShare =
                  '${dhikr?.arabic}\n\n${dhikr?.translation}\n\n${dhikr?.count}';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: dhikr?.title != null,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${dhikr?.title}',
                              style: context.titleMediumBold?.copyWith(
                                color: context.colorPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${dhikr?.count}',
                                style: context.titleMediumBold?.copyWith(
                                  color: context.colorPrimary,
                                ),
                              ),
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
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: context.colorPrimary,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: templateShare));
                              context
                                  .showSuccessMessage('Berhasil menyalin teks');
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SelectableText(
                          '${dhikr?.arabic}',
                          textAlign: TextAlign.end,
                          style: context.displaySmall?.copyWith(
                            fontFamily: FontFamily.uthmanic,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Visibility(
                        visible: dhikr?.transliteration != null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4),
                          child: Text(
                            '${dhikr?.transliteration}',
                            style: context.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: context.colorPrimary,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '${dhikr?.translation}',
                          style: context.bodyLarge,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Visibility(
                        visible: dhikr?.faedah != null,
                        child: InkWell(
                          onTap: () {
                            showOkAlertDialog(
                              context: context,
                              title: 'Catatan Kaki',
                              message: '${dhikr?.reference}',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8,
                            ),
                            child: Text(
                              '${dhikr?.faedah}',
                              style: context.bodyMedium?.copyWith(
                                color: context.colorPrimary,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
