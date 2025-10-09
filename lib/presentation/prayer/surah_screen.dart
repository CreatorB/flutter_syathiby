import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';
import 'package:syathiby/presentation/prayer/quran.dart';
import 'package:syathiby/presentation/prayer/quran_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SurahScreen extends HookConsumerWidget {
  const SurahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchSurahList = ref.watch(fetchSurahListProvider);
    final scrollController = useMemoized(
      () => AnchorScrollController(),
    );
    final itemCount =
        fetchSurahList.isLoading ? 10 : fetchSurahList.valueOrNull?.length ?? 0;
    final lastReadQuran = ref.watch(getLastReadQuranProvider);
    final bookmarkQuran = ref.watch(getBookmarkQuranProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Surah>(
                  items: fetchSurahList.valueOrNull ?? [],
                  searchLabel: 'Cari nama surat',
                  failure: const Center(
                    child: Text('Nama surat tidak ditemukan'),
                  ),
                  filter: (surah) => [
                    surah.namaLatin,
                    surah.nama,
                  ],
                  builder: (surah) => _buildItemSurah(
                    context,
                    surah,
                    lastReadQuran.valueOrNull,
                    bookmarkQuran.valueOrNull,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchSurahListProvider.future),
        child: Skeletonizer(
          enabled: fetchSurahList.isLoading,
          child: ListView.builder(
            controller: scrollController,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final surah = fetchSurahList.valueOrNull?.elementAtOrNull(index);
              return AnchorItemWrapper(
                controller: scrollController,
                index: index,
                child: _buildItemSurah(
                  context,
                  surah,
                  bookmarkQuran.valueOrNull,
                  lastReadQuran.valueOrNull,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItemSurah(
    BuildContext context,
    Surah? surah,
    Quran? bookmarkQuran,
    Quran? lastReadQuran,
  ) {
    final isFirstItem = surah?.nomor == 1;
    return Column(
      children: [
        Visibility(
          visible: isFirstItem,
          child: _buildItemSurahHeader(
            context,
            surah,
            bookmarkQuran,
            lastReadQuran,
          ),
        ),
        ListTile(
          title: Text('${surah?.namaLatin} - ${surah?.nama}'),
          subtitle: Text('${surah?.arti} - ${surah?.jumlahAyat} ayat'),
          leading: CircleAvatar(
            backgroundColor: context.colorPrimary,
            child: Text(
              '${surah?.nomor}',
              style: TextStyle(color: context.colorOnPrimary),
            ),
          ),
          onTap: () {
            context.goNamed(
              AppRoute.ayah.name,
              extra: surah,
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemSurahHeader(
    BuildContext context,
    Surah? surah,
    Quran? bookmarkQuran,
    Quran? lastReadQuran,
  ) {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              if (bookmarkQuran == null || surah == null) {
                context.showErrorMessage('Belum ada penanda baca');
                return;
              }
              context.goNamed(
                AppRoute.ayah.name,
                extra: bookmarkQuran.surah,
                queryParameters: {
                  "jump_to_ayah_number": bookmarkQuran.ayah.aya
                },
              );
            },
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          bookmarkQuran == null
                              ? Icons.bookmark_added_outlined
                              : Icons.bookmark_added,
                          color: context.colorPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Penanda Baca'.hardcoded,
                          style: context.bodyLargeBold?.copyWith(
                            color: context.colorPrimary,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${bookmarkQuran?.surah.namaLatin ?? '-'} : ${bookmarkQuran?.ayah.aya ?? '-'}',
                      style: context.bodyMediumBold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () {
              if (lastReadQuran == null || surah == null) {
                context.showErrorMessage('Belum ada ayat terakhir baca');
                return;
              }
              context.goNamed(
                AppRoute.ayah.name,
                extra: lastReadQuran.surah,
                queryParameters: {
                  "jump_to_ayah_number": lastReadQuran.ayah.aya
                },
              );
            },
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          lastReadQuran == null
                              ? Icons.book_outlined
                              : Icons.book,
                          color: context.colorPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terakhir Baca'.hardcoded,
                          style: context.bodyLargeBold?.copyWith(
                            color: context.colorPrimary,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lastReadQuran?.surah.namaLatin ?? '-'} : ${lastReadQuran?.ayah.aya ?? '-'}',
                      style: context.bodyMediumBold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
