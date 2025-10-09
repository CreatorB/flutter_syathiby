import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/prayer/murottal/murottal.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class ReciterItem extends HookConsumerWidget {
  final Murottal murottal;
  final Reciter reciter;
  final Function(Murottal murottal, Reciter reciter) onTap;
  final bool isSelected;

  const ReciterItem({
    super.key,
    required this.murottal,
    required this.reciter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        onTap(murottal, reciter);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.all(2),
        child: Card.outlined(
          color: isSelected ? context.colorPrimaryContainer : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isSelected
                  ? context.colorPrimary
                  : context.colorOutline.withOpacity(0.38),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomAvatar(
                    name: reciter.reciterName,
                    size: 56,
                    imageUrl: '${reciter.photoUrl}',
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      reciter.reciterName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isSelected,
                child: Positioned(
                  top: 6,
                  right: 2,
                  child: Icon(
                    Icons.check_circle,
                    color: context.colorPrimary,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
