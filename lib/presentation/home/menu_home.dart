import 'dart:async';

import 'package:flutter/material.dart';

typedef MenuTapCallback = FutureOr<void> Function();

class MenuGrid {
  final String title;
  final dynamic iconData;
  final String goToRouteName;
  final Object? extra;
  final Map<String, dynamic>? queryParameters;
  final MenuTapCallback? onClicked;
  final MenuTapCallback? preload;

  MenuGrid({
    required this.title,
    required this.iconData,
    required this.goToRouteName,
    this.extra,
    this.onClicked,
    this.preload,
    this.queryParameters,
  });
}
