import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/search/duplicates.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

/// Returns true when the user may save. No matches means no dialog.
Future<bool> confirmDuplicates(
  BuildContext context,
  WidgetRef ref,
  List<BookDraft> drafts,
) async {
  final repository = ref.read(libraryRepositoryProvider);
  final blocks = <String>[];
  for (final draft in drafts) {
    if (draft.title.trim().isEmpty) {
      continue;
    }
    if (drafts.length > 1 && draft.savedBookId != null) {
      continue;
    }
    final matches = await repository.findDuplicates(
      draft,
      excludeId: draft.savedBookId,
    );
    if (matches.isEmpty) {
      continue;
    }
    final lines = [
      for (final match in matches)
        '${duplicateReasonLabel(match.reason)}: «${match.title}»\n${match.locationPath}',
    ].join('\n');
    blocks.add('«${draft.title.trim()}»\n$lines');
  }
  if (blocks.isEmpty) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  return confirmDialog(
    context,
    title: 'Похожий экземпляр уже есть',
    message: '${blocks.join('\n\n')}\n\nСохранить всё равно?',
    confirmLabel: 'Сохранить',
  );
}
