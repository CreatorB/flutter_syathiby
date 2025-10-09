import 'package:flutter/material.dart';

class MenuGrid {
  final String title;
  final dynamic iconData;
  final String goToRouteName;
  final Object? extra;
  final Map<String, dynamic>? queryParameters;
  final VoidCallback? onClicked;

  MenuGrid({
    required this.title,
    required this.iconData,
    required this.goToRouteName,
    this.extra,
    this.onClicked,
    this.queryParameters,
  });
}
