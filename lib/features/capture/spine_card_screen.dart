import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/features/books/book_editor.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/duplicate_prompt.dart';

class SpineCardScreen extends ConsumerWidget {
  const SpineCardScreen({
    super.key,
    required this.initial,
    this.heading = 'Карточка книги',
  });

  final BookDraft initial;
  final String heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BookEditor(
      initial: initial,
      heading: heading,
      lookupOnOpen: true,
      onSkip: () async {
        if (context.mounted) {
          Navigator.pop(context, false);
        }
      },
      onSave: (draft) async {
        final allowed = await confirmDuplicates(context, ref, [draft]);
        if (!allowed || !context.mounted) {
          return;
        }
        final id = await ref.read(libraryRepositoryProvider).createBook(draft);
        await ref.read(appLogProvider).write(
          'Книга сохранена',
          '«${draft.title}», id $id',
        );
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
    );
  }
}
