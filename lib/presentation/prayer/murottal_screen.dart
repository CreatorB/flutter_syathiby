import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/prayer/murottal/murottal.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';
import 'package:syathiby/presentation/prayer/quran_controller.dart';
import 'package:syathiby/presentation/prayer/reciter_item.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'audio_player_screen.dart';
import 'murottal_controller.dart';

class MurottalScreen extends HookConsumerWidget {
  const MurottalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchSurahList = ref.watch(fetchSurahListProvider);
    final fetchMurottal = ref.watch(fetchMurottalSurahProvider);
    final murottalSelected = ref.watch(getMurottalSelectedProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerState = useMemoized(() => audioPlayer.playerStateStream, []);
    final playerStateSnapshot = useStream(playerState);
    final isPlaying = playerStateSnapshot.data?.playing == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Murottal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Visibility(
              visible: isPlaying,
              child: IconButton(
                onPressed: () {
                  audioPlayer.stop();
                  context.pop(true);
                },
                icon: const Icon(Icons.stop),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchSurahListProvider.future),
        child: Skeletonizer(
          enabled: fetchSurahList.isLoading || fetchMurottal.isLoading,
          child: ListView(
            children: [
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fetchMurottal.valueOrNull?.length ?? 0,
                  itemBuilder: (context, index) {
                    final murottal =
                        fetchMurottal.valueOrNull?.elementAtOrNull(index);
                    if (murottal == null) return Container();
                    final reciters = murottal.reciters;
                    final reciterNameSelected = murottalSelected
                        .valueOrNull?.reciters.firstOrNull?.reciterName;
                    return Row(
                      children: reciters
                          .map(
                            (reciter) => ReciterItem(
                              murottal: murottal,
                              reciter: reciter,
                              isSelected:
                                  reciter.reciterName == reciterNameSelected,
                              onTap: (murottal, reciter) async {
                                final data = murottal.copyWith(
                                  reciters: [reciter],
                                );
                                await ref.read(
                                  saveMurottalSelectedProvider(data).future,
                                );
                                ref.invalidate(getMurottalSelectedProvider);
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: fetchSurahList.valueOrNull?.length ?? 10,
                itemBuilder: (context, index) {
                  final surah =
                      fetchSurahList.valueOrNull?.elementAtOrNull(index);
                  return ListTile(
                    title: Text('${surah?.namaLatin} - ${surah?.nama}'),
                    subtitle:
                        Text('${surah?.arti} - ${surah?.jumlahAyat} ayat'),
                    leading: CircleAvatar(
                      backgroundColor: context.colorPrimary,
                      child: Text(
                        '${surah?.nomor}',
                        style: TextStyle(color: context.colorOnPrimary),
                      ),
                    ),
                    onTap: () async {
                      final selected = murottalSelected.value;
                      if (selected == null) {
                        context.showErrorMessage(
                          'Silahkan pilih qori terlebih dahulu',
                        );
                        return;
                      }
                      _playOrPauseSurah(
                        audioPlayer,
                        surah,
                        murottalSelected.value,
                        index,
                      );
                      final isClosed = await showModalBottomSheet<bool>(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        context: context,
                        builder: (context) => FractionallySizedBox(
                          heightFactor: 0.9,
                          child: AudioPlayerScreen(
                            audioPlayer: audioPlayer,
                            murottal: selected,
                          ),
                        ),
                        isScrollControlled: true,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playOrPauseSurah(
    AudioPlayer player,
    Surah? surah,
    Murottal? murottal,
    int indexId,
  ) async {
    if (surah == null || murottal == null) return;

    final reciter = murottal.reciters.firstOrNull;
    final surahNumber =
        surah.nomor.toString().padLeft(murottal.paddingSurahNumber, '0');
    // Example: https://media.blubrry.com/muslim_central_quran/podcasts.qurancentral.com/abu-bakr-al-shatri/abu-bakr-al-shatri-----055.mp3
    final audioUrl =
        '${murottal.baseUrl}${reciter?.endPoint}${murottal.separator ?? ''}$surahNumber${murottal.extension}';
    debugPrint('CHECK URL: $audioUrl');
    final audio = AudioSource.uri(
      Uri.parse(audioUrl),
      tag: MediaItem(
          id: indexId.toString(),
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
}
