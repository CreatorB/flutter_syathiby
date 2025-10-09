import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:syathiby/models/prayer/murottal/murottal.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AudioPlayerScreen extends HookConsumerWidget {
  final AudioPlayer audioPlayer;
  final Murottal murottal;

  const AudioPlayerScreen({
    super.key,
    required this.audioPlayer,
    required this.murottal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlayingItem =
        audioPlayer.audioSource?.sequence.firstOrNull?.tag as MediaItem?;
    final playerState = useMemoized(() => audioPlayer.playerStateStream, []);
    final playerStateSnapshot = useStream(playerState);
    final isLoading = useMemoized(() => audioPlayer.load());
    final loadingSnapshot = useFuture(isLoading);
    final isPlaying = playerStateSnapshot.data?.playing == true;
    return Skeletonizer(
      enabled: loadingSnapshot.data == null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${currentPlayingItem?.title}',
          ),
          leading: IconButton(
            onPressed: () {
              context.pop(true);
            },
            icon: const Icon(Icons.close),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: IconButton(
                onPressed: () {
                  audioPlayer.stop();
                  context.pop(true);
                },
                icon: const Icon(Icons.stop),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                CachedNetworkImage(
                  imageUrl: '${currentPlayingItem?.artUri}',
                  imageBuilder: (context, imageProvider) => AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => AspectRatio(
                    aspectRatio: 1 / 1,
                    child: AdvancedAvatar(
                      name: '${currentPlayingItem?.artist}',
                      autoTextSize: true,
                      size: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${currentPlayingItem?.artist}',
                  textAlign: TextAlign.center,
                  style: context.headlineMediumBold,
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentPlayingItem?.title}',
                  textAlign: TextAlign.center,
                  style: context.titleLarge?.copyWith(
                    color: context.colorOnSurface.withOpacity(0.68),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: FloatingActionButton(
                    onPressed: isPlaying ? audioPlayer.pause : audioPlayer.play,
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
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
