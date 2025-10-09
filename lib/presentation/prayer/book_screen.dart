import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'hadith_controller.dart';

class BooksScreen extends HookConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchBooks = ref.watch(fetchBookListProvider);
    final books = fetchBooks.valueOrNull?.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kitab Hadits'.hardcoded,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchBookListProvider.future),
        child: Skeletonizer(
          enabled: fetchBooks.isLoading,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: books?.length ?? 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemBuilder: (context, index) {
              final book = books?[index];
              final bookName = book?.name.replaceAll('HR. ', '');
              final initialBook = getInitials(bookName);
              return InkWell(
                onTap: () {
                  if (book == null) return;
                  context.goNamed(AppRoute.hadith.name, extra: book);
                },
                child: SizedBox(
                  height: 180,
                  child: Card.outlined(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$initialBook',
                            style: context.displayMedium?.copyWith(
                              color: context.colorPrimary,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '$bookName',
                            style: context.titleLargeBold,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${book?.available} hadits',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: context.colorOnSurface.withOpacity(
                                0.60,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? getInitials(String? name) {
    if (name == null) return null;
    List<String> nameSplit = name.split(" ");
    String initials = "";
    int numWords =
        2; // You can change this to specify how many initials you want

    if (nameSplit.length < numWords) {
      numWords = nameSplit.length;
    }

    for (var i = 0; i < numWords; i++) {
      initials += nameSplit[i][0];
    }

    return initials.toUpperCase();
  }
}
