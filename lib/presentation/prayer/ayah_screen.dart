import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:anchor_scroll_controller/anchor_scroll_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/generated/fonts.gen.dart';
import 'package:syathiby/models/prayer/ayah/ayah_response.dart';
import 'package:syathiby/models/prayer/murottal/murottal.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';
import 'package:syathiby/presentation/prayer/quran.dart';
import 'package:syathiby/presentation/prayer/quran_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'murottal_controller.dart';

class AyahScreen extends HookConsumerWidget {
  final Surah surah;
  final int? jumpToAyahNumber;

  const AyahScreen({
    super.key,
    required this.surah,
    this.jumpToAyahNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchAyahList = ref.watch(
      fetchAyahListProvider(surahNumber: surah.nomor),
    );
    final fetchMurottal = ref.watch(fetchMurottalEveryAyahProvider);
    final murottalSelected = ref.watch(getMurottalAyahSelectedProvider);
    final player = ref.watch(audioPlayerProvider);
    final bookmarkQuran = ref.watch(getBookmarkQuranProvider);
    final ayahList = fetchAyahList.valueOrNull?.result;
    final controller = useMemoized(() => AnchorScrollController(), []);

    useEffect(() {
      controller.addIndexListener(
        (index, userScroll) async {
          if (!userScroll) return;
          final currentAyah = ayahList?[index];
          if (currentAyah == null) return;
          await ref.read(
            saveLastReadQuranProvider(
              quran: Quran(ayah: currentAyah, surah: surah),
            ).future,
          );
          debugPrint('CHECK onIndexChanged SAVED: ');
        },
      );
      if (jumpToAyahNumber == null || ayahList == null) return null;
      final index = jumpToAyahNumber!;
      debugPrint('CHECK INDX: $index $jumpToAyahNumber ${ayahList.length}');
      controller.scrollToIndex(
        index: index,
        scrollSpeed: 14,
      );
      return null;
    }, [ayahList]);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${surah.namaLatin} - ${surah.nama}',
              style: context.titleMedium,
            ),
            Text(
              '${surah.arti} - ${surah.jumlahAyat} ayat',
              style: context.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await _showQoriDialog(
                context,
                fetchMurottal.valueOrNull,
                murottalSelected.valueOrNull,
              );
              if (selected == null) return;
              await ref.read(
                saveMurottalAyahSelectedProvider(selected).future,
              );
              ref.invalidate(getMurottalAyahSelectedProvider);
              final reciterName =
                  selected.reciters.firstOrNull?.reciterName ?? '';
              context
                  .showSuccessMessage('Berhasil menyimpan qori: $reciterName');
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Ayah>(
                  items: fetchAyahList.valueOrNull?.result ?? [],
                  searchLabel: 'Pencarian...',
                  failure: const Center(
                    child: Text('Ayat tidak ditemukan'),
                  ),
                  filter: (surah) => [
                    surah.translation,
                    surah.arabicText,
                  ],
                  builder: (ayah) => _buildItemAyah(
                    ref: ref,
                    context: context,
                    ayah: ayah,
                    player: player,
                    murottalSelected: murottalSelected,
                    controller: controller,
                    bookmarkQuran: bookmarkQuran.valueOrNull,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAyahListProvider(surahNumber: surah.nomor).future,
        ),
        child: Skeletonizer(
          enabled: fetchAyahList.isLoading,
          child: ListView.builder(
            controller: controller,
            itemCount: ayahList?.length ?? 10,
            itemBuilder: (context, index) {
              final ayah = ayahList?[index];
              return _buildItemAyah(
                ref: ref,
                context: context,
                ayah: ayah,
                player: player,
                murottalSelected: murottalSelected,
                controller: controller,
                bookmarkQuran: bookmarkQuran.valueOrNull,
              );
            },
          ),
        ),
      ),
    );
  }

  void _shareAyah(Ayah ayah, Surah surah) {
    final template =
        '${ayah.arabicText}\n\n${ayah.translation}\n\n(QS.${surah.namaLatin}: ${ayah.aya})';
    Share.share(template);
  }

  void _copyAyah(Ayah ayah, Surah surah) {
    final template =
        '${ayah.arabicText}\n\n${ayah.translation}\n\n(QS.${surah.namaLatin}: ${ayah.aya})';
    Clipboard.setData(ClipboardData(text: template));
  }

  Future<void> _playOrPauseAyah(
    AudioPlayer player,
    Surah? surah,
    Ayah? ayah,
    Murottal? murottal,
  ) async {
    if (surah == null || murottal == null) return;

    final reciter = murottal.reciters.firstOrNull;
    final surahNumber =
        surah.nomor.toString().padLeft(murottal.paddingSurahNumber, '0');
    final ayahNumber =
        ayah?.aya.toString().padLeft(murottal.paddingAyahNumber ?? 3, '0');
    final audioUrl =
        '${murottal.baseUrl}${reciter?.endPoint}${murottal.separator ?? ''}$surahNumber$ayahNumber${murottal.extension}';
    debugPrint('CHECK URL: $audioUrl');
    final audio = AudioSource.uri(
      Uri.parse(audioUrl),
      tag: MediaItem(
          id: '${ayah?.id}',
          album: 'Al-Qur\'an',
          title: surah.namaLatin,
          artUri: reciter?.photoUrl != null
              ? Uri.parse('${reciter?.photoUrl}')
              : null,
          artist: '${reciter?.reciterName}'),
    );
    final duration = await player.setAudioSource(audio);
    player.play();
  }

  TextSpan buildTextSpan(
    BuildContext context,
    String text, {
    required VoidCallback onClick,
    double? fontSize,
  }) {
    RegExp regExp = RegExp(r'\d+');
    Iterable<RegExpMatch> matches = regExp.allMatches(text);

    List<TextSpan> children = [];

    int lastIndex = 0;
    for (RegExpMatch match in matches) {
      children.add(
        TextSpan(
          text: text.substring(lastIndex, match.start),
        ),
      );

      children.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontFeatures: const [FontFeature.superscripts()],
            color: context.colorPrimary,
            fontSize: 24,
          ),
          recognizer: TapGestureRecognizer()..onTap = onClick,
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last number
    if (lastIndex < text.length) {
      children.add(
        TextSpan(
          text: text.substring(lastIndex),
        ),
      );
    }

    return TextSpan(
      children: children,
      style: TextStyle(
        color: context.colorOnSurface,
        fontSize: fontSize,
      ),
    );
  }

  Future<Murottal?> _showQoriDialog(
    BuildContext context,
    List<Murottal>? murottalList,
    Murottal? murottalSelected,
  ) async {
    if (murottalList == null) return null;
    final reciters = murottalList.expand((e) => e.reciters).toList();
    final selected = await showConfirmationDialog<Reciter>(
      context: context,
      title: 'Pilih Qori',
      actions: reciters
          .map(
            (e) => AlertDialogAction(key: e, label: e.reciterName),
          )
          .toList(),
    );
    if (selected == null) {
      return null;
    }
    final murottal = murottalList.firstWhere(
      (element) => element.reciters.contains(selected),
    );
    final data = murottal.copyWith(reciters: [selected]);
    return data;
  }

  Widget _buildItemAyah({
    required WidgetRef ref,
    required BuildContext context,
    required Ayah? ayah,
    required AudioPlayer player,
    required AsyncValue<Murottal?> murottalSelected,
    required AnchorScrollController controller,
    required Quran? bookmarkQuran,
  }) {
    final isBookmarked = bookmarkQuran?.surah.nomor == surah.nomor &&
        bookmarkQuran?.ayah.aya == ayah?.aya;

    return AnchorItemWrapper(
      controller: controller,
      index: int.tryParse('${ayah?.aya}') ?? -1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  Text(
                    '${ayah?.aya}',
                    style: context.titleLargeBold?.copyWith(
                      color: context.colorPrimary,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: context.colorPrimary,
                    ),
                    onPressed: () async {
                      if (ayah == null) return;
                      final quran = Quran(surah: surah, ayah: ayah);
                      await ref.read(
                        saveBookmarkQuranProvider(quran: quran).future,
                      );
                      context.showSuccessMessage(
                          'Berhasil menyimpan penanda ayat');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: context.colorPrimary,
                    ),
                    onPressed: () {
                      if (ayah == null) return;
                      _shareAyah(ayah, surah);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: context.colorPrimary,
                    ),
                    onPressed: () {
                      if (ayah == null) return;
                      _copyAyah(ayah, surah);
                      context.showSuccessMessage('Berhasil menyalin ayat');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.play_circle,
                      color: context.colorPrimary,
                    ),
                    onPressed: () {
                      if (ayah == null || murottalSelected.value == null) {
                        context.showErrorMessage(
                          'Silahkan pilih qori terlebih dahulu, klik icon bentuk orang',
                        );
                        return;
                      }
                      _playOrPauseAyah(
                        player,
                        surah,
                        ayah,
                        murottalSelected.value,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${ayah?.arabicText}',
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
              child: RichText(
                text: buildTextSpan(
                  context,
                  '${ayah?.translation}',
                  fontSize: 16,
                  onClick: () {
                    showOkAlertDialog(
                      context: context,
                      title: 'Catatan Kaki',
                      message: '${ayah?.footnotes}',
                    );
                  },
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
