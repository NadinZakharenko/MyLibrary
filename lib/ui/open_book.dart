import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The book card opens inside the tab (or the batch wizard) it was opened from.
String bookLocation(BuildContext context, int id) {
  final path = GoRouterState.of(context).uri.path;
  return '${_bookPrefix(path)}/book/$id';
}

void openBook(BuildContext context, int id) {
  context.push(bookLocation(context, id));
}

String _bookPrefix(String path) {
  for (final prefix in const ['/add/batch', '/search', '/add']) {
    if (path == prefix || path.startsWith('$prefix/')) {
      return prefix;
    }
  }
  return '/home';
}
