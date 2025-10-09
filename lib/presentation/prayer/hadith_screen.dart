import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/generated/fonts.gen.dart';
import 'package:syathiby/models/prayer/hadith/book_response.dart';
import 'package:syathiby/models/prayer/hadith/hadith_response.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:share_plus/share_plus.dart';

import 'hadith_controller.dart';
import 'hadith_detail_screen.dart';

class HadithScreen extends HookConsumerWidget {
  final Book book;

  const HadithScreen({super.key, required this.book});

  static const int pagedSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = useMemoized(
      () => PagingController<int, Hadith>(
        firstPageKey: 1,
      ),
    );

    Future<void> fetchData(int pageKey, int pageSize) async {
      try {
        final to = (pageKey - 1) + pagedSize;
        final range = '$pageKey-$to';
        final result = await ref.watch(
          fetchHadithListProvider(
            bookId: book.id,
            range: range,
          ).future,
        );
        final data = result.data.hadiths;
        final isLastPage = data.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(data);
        } else {
          final nextPageKey = pageKey + data.length;
          pagingController.appendPage(data, nextPageKey);
        }
      } catch (error) {
        pagingController.error = error;
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener((pageKey) {
        fetchData(pageKey, pagedSize);
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.name,
              style: context.titleMedium,
            ),
            Text(
              '${book.available} hadits',
              style: context.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final value = await _showInputDialog(
                context,
                'Cari Nomor Hadits',
                'Nomor Hadits',
              );
              if (value == null || !context.mounted) return;
              final hadithNumber = int.parse(value);

              _showBookDetailModal(context, book.id, hadithNumber);
            },
            icon: const Icon(Icons.manage_search),
          ),
          IconButton(
            onPressed: () async {
              final value = await _showInputDialog(
                  context, 'Scroll Nomor Urutan', 'Nomor Urutan');
              if (value == null) return;
              final hadithNumber = int.parse(value);
              pagingController.itemList = [];
              pagingController.notifyPageRequestListeners(hadithNumber);
            },
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => Future.sync(() => pagingController.refresh()),
        child: PagedListView(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Hadith>(
            itemBuilder: (context, hadith, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Row(
                        children: [
                          Text(
                            'Hadits No. ${hadith.number}',
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
                              _share(book, hadith);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: context.colorPrimary,
                            ),
                            onPressed: () {
                              _copy(book, hadith);
                              context.showSuccessMessage(
                                  'Berhasil menyalin hadits');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        hadith.arab,
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
                        hadith.id,
                        style: context.bodyLarge,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String?> _showInputDialog(
    BuildContext context,
    String title,
    String hint,
  ) async {
    final result = await showTextInputDialog(
      context: context,
      title: title,
      textFields: [
        DialogTextField(
          hintText: hint,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null) return 'Angka tidak boleh kosong';
            if (int.tryParse(value) == null) return 'Isikan berupa angka';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final value = result?.firstOrNull;
    return value;
  }

  void _share(Book book, Hadith hadith) {
    final template =
        '${hadith.arab}\n\n${hadith.id}\n\n(${book.name}: ${hadith.number})';
    Share.share(template);
  }

  void _copy(Book book, Hadith hadith) {
    final template =
        '${hadith.arab}\n\n${hadith.id}\n\n(${book.name}: ${hadith.number})';
    Clipboard.setData(ClipboardData(text: template));
  }

  Future<void> _showBookDetailModal(
    BuildContext context,
    String id,
    int hadithNumber,
  ) async {
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: HadithDetailScreen(
          hadithDetail: HadithDetail(book.id, hadithNumber),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
