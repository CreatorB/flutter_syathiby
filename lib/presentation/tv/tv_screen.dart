import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/tv/tv_controller.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../di/providers.dart';

class TvScreen extends HookConsumerWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchTv = ref.watch(fetchTvProvider(key: key));
    final tv = fetchTv.valueOrNull?.firstOrNull;
    final ytController = YoutubePlayerController(
      initialVideoId: '${tv?.img}',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        hideControls: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstant.youtubeChannelName),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchTvProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchTv.isLoading,
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: ytController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: context.colorPrimary,
                  progressColors: ProgressBarColors(
                    playedColor: context.colorPrimary,
                    handleColor: context.colorPrimaryContainer,
                  ),
                  onReady: () {
                    // ytController.addListener(() {
                    //
                    // },);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 12,
                  bottom: 4,
                ),
                child: Text(
                  '${tv?.title}',
                  style: context.titleLargeBold,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text(
                  _parseHtmlString('${tv?.detail}'),
                  style: context.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    final htmlDocument = HtmlParser.parseHTML(htmlString);
    return htmlDocument.text;
  }
}
