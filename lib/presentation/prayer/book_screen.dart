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
              return _BookCard(
                initialize: initialBook,
                bookName: bookName,
                available: book?.available,
                onTap: () {
                  if (book == null) return;
                  context.goNamed(AppRoute.hadith.name, extra: book);
                },
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

class _BookCard extends StatefulWidget {
  final String? initialize;
  final String? bookName;
  final int? available;
  final VoidCallback onTap;

  const _BookCard({
    required this.initialize,
    required this.bookName,
    required this.available,
    required this.onTap,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation.drive(Tween<double>(begin: 0.80, end: 1.0)),
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            // Gradient background for 3D effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorSurface,
                context.colorPrimaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            // Multiple shadow layers for 3D depth
            boxShadow: [
              // Top-left highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(-2, -2),
                blurRadius: 6,
                spreadRadius: 0,
              ),
              // Bottom-right main shadow
              BoxShadow(
                color: context.colorPrimary.withOpacity(0.25),
                offset: const Offset(4, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              // Additional depth shadow
              BoxShadow(
                color: context.colorPrimary.withOpacity(0.15),
                offset: const Offset(6, 6),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
            // Border for definition
            border: Border.all(
              color: context.colorPrimary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.initialize}',
                  style: context.displayMedium?.copyWith(
                    color: context.colorPrimary,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: context.colorPrimary.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${widget.bookName}',
                  style: context.titleLargeBold?.copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${widget.available} hadits',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
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
  }
}
