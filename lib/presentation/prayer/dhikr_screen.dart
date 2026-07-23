import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/generated/fonts.gen.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/prayer/dhikr/dhikr.dart';
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
    final dhikrCounts = useState<Map<int, int>>({});

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
          child: Builder(
            builder: (context) {
              if (fetchDhikr.hasError && !fetchDhikr.isLoading) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Gagal memuat data. Mohon periksa koneksi internet Anda.',
                          style: context.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }

              final dhikrList = fetchDhikr.valueOrNull ?? [];

              return ListView.builder(
                itemCount: fetchDhikr.isLoading ? 10 : dhikrList.length,
                itemBuilder: (context, index) {
                  final dhikr = dhikrList.elementAtOrNull(index);
                  if (dhikr == null && !fetchDhikr.isLoading) {
                    return const SizedBox.shrink();
                  }

                  return DhikrItemCard(
                    dhikr: dhikr,
                    index: index,
                    isLoading: fetchDhikr.isLoading,
                    currentCount: dhikrCounts.value[index] ?? 0,
                    onCountChanged: (newCount) {
                      final newMap = Map<int, int>.from(dhikrCounts.value);
                      newMap[index] = newCount;
                      dhikrCounts.value = newMap;
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class DhikrItemCard extends StatelessWidget {
  final Dhikr? dhikr;
  final int index;
  final bool isLoading;
  final int currentCount;
  final ValueChanged<int> onCountChanged;

  const DhikrItemCard({
    super.key,
    this.dhikr,
    required this.index,
    this.isLoading = false,
    required this.currentCount,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final target = dhikr?.targetCount ?? 1;
    final isFinished = currentCount >= target;

    // Alternating background color
    final backgroundColor = index % 2 == 0
        ? Colors.transparent
        : context.colorPrimary.withOpacity(0.05);

    final templateShare =
        '${dhikr?.arabic ?? "..."}\n\n${dhikr?.translation ?? "..."}\n\nDibaca ${dhikr?.targetCount ?? "..."}x';

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Title (if exists)
          Visibility(
            visible: dhikr?.title != null || isLoading,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Text(
                dhikr?.title ?? 'Judul Dzikir',
                style: context.titleMediumBold?.copyWith(
                  color: context.colorPrimary,
                ),
              ),
            ),
          ),

          // 2. Arabic Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SelectableText(
              dhikr?.arabic ?? 'اللَّهُ',
              textAlign: TextAlign.end,
              style: context.displaySmall?.copyWith(
                fontFamily: FontFamily.uthmanic,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Latin (Transliteration)
          Visibility(
            visible: dhikr?.transliteration != null || isLoading,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Text(
                dhikr?.transliteration ?? 'Transliteration placeholder',
                style: context.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: context.colorPrimary,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),

          // 4. Terjemah (Translation)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              dhikr?.translation ?? 'Terjemahan placeholder',
              style: context.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ),

          const SizedBox(height: 12),

          // 5. Riwayat (Reference) & 6. Faidah
          Visibility(
            visible: dhikr?.faedah != null || isLoading,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: InkWell(
                onTap: () {
                  if (dhikr?.reference != null) {
                    showOkAlertDialog(
                      context: context,
                      title: 'Riwayat / Catatan Kaki',
                      message: '${dhikr?.reference}',
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faidah:',
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorPrimary,
                      ),
                    ),
                    Text(
                      dhikr?.faedah ?? 'Faedah placeholder',
                      style: context.bodyMedium?.copyWith(
                        color: context.colorPrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 0. Progress Step / Tap Component
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: 'Tap untuk menambah hitungan',
                    child: InkWell(
                      onTap: isLoading || isFinished
                          ? null
                          : () {
                              if (currentCount < target) {
                                final nextCount = currentCount + 1;
                                onCountChanged(nextCount);
                                if (nextCount == target) {
                                  HapticFeedback.heavyImpact();
                                } else {
                                  HapticFeedback.lightImpact();
                                }
                              }
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: $currentCount/$target x',
                                style: context.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isFinished
                                      ? Colors.green
                                      : context.colorPrimary,
                                ),
                              ),
                              if (isFinished)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: target > 0 ? currentCount / target : 0,
                              backgroundColor:
                                  context.colorPrimary.withOpacity(0.1),
                              color: isFinished
                                  ? Colors.green
                                  : context.colorPrimary,
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: context.colorPrimary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          Share.share(templateShare);
                        },
                ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    color: context.colorPrimary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: templateShare));
                          context.showSuccessMessage('Berhasil menyalin teks');
                        },
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: context.colorPrimary.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          onCountChanged(0);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
