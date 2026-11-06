import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openCabinetAtShelf(
  BuildContext context, {
  required int? cabinetId,
  required int? shelfId,
}) {
  if (cabinetId == null) {
    return;
  }
  final query = shelfId == null ? '' : '?shelf=$shelfId';
  context.go('/home/cabinet/$cabinetId$query');
}
