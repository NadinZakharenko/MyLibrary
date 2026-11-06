import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/logging/app_log.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/library_view.dart';
import 'package:my_library/core/models/reading_status.dart';
import 'package:my_library/data/livelib_account.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/open_url.dart';

bool showCatalogSend({required String note, required bool allowed}) {
  return note.trim().isNotEmpty && allowed;
}

class BookCatalogActions extends ConsumerWidget {
  const BookCatalogActions({super.key, required this.book});

  final BookDetails book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yandexId = book.yandexId.trim().isNotEmpty
        ? book.yandexId.trim()
        : yandexAudiobookIdFromUrl(book.sourceUrl);
    final consent = ref.watch(catalogSendConsentProvider).asData?.value;
    final livelib = book.format == BookFormat.print &&
        (book.sourceUrl.contains('livelib.ru/book/') || book.isbn.trim().isNotEmpty) &&
        showCatalogSend(
          note: book.personalNote,
          allowed: consent?.livelib ?? false,
        );
    final yandexSend = book.format == BookFormat.audio &&
        yandexId != null &&
        showCatalogSend(
          note: book.personalNote,
          allowed: consent?.yandexBooks ?? false,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (yandexSend) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _yandex(context, ref, yandexId),
            child: const Text('Отправить в Яндекс Книги'),
          ),
        ],
        if (livelib) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _liveLib(context, ref),
            child: const Text('Отправить на LiveLib'),
          ),
        ],
      ],
    );
  }

  Future<void> _yandex(BuildContext context, WidgetRef ref, String yandexId) async {
    await Clipboard.setData(ClipboardData(text: book.personalNote));
    if (!context.mounted) {
      return;
    }
    await openExternalPage(context, yandexAudiobookUrl(yandexId));
    const message = 'Заметка скопирована. Откройте отзыв в Яндекс Книгах.';
    await ref.read(appLogProvider).writeAlways('Яндекс Книги', message);
    if (context.mounted) {
      showMessage(context, message);
    }
  }

  Future<void> _liveLib(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(libraryRepositoryProvider);
    final allowed = await repository.livelibSendConsent();
    final login = (await repository.livelibLogin())?.trim() ?? '';
    final password = await repository.livelibPassword() ?? '';
    if (!context.mounted) {
      return;
    }
    if (!allowed || login.isEmpty || password.isEmpty) {
      const message = 'Включите отправку в настройках LiveLib и сохраните логин с паролем.';
      await ref.read(appLogProvider).writeAlways('LiveLib', message);
      if (context.mounted) {
        showMessage(context, message);
      }
      return;
    }
    final url = book.sourceUrl.contains('livelib.ru/book/')
        ? book.sourceUrl
        : 'https://www.livelib.ru/find/${Uri.encodeComponent(book.isbn)}';
    final account = LiveLibAccount();
    try {
      final result = await account.send(
        login: login,
        password: password,
        bookUrl: url,
        statusLabel: readingStatusLabel(book.readingStatus),
        reviewTitle: book.title,
        review: book.personalNote,
        rating: book.readerRating,
      );
      if (!context.mounted) {
        return;
      }
      if (!result.ok) {
        await Clipboard.setData(ClipboardData(text: book.personalNote));
        if (!context.mounted) {
          return;
        }
        await openExternalPage(context, url);
      }
      if (context.mounted) {
        showMessage(context, result.ok ? result.message : '${result.message} Текст рецензии скопирован.');
      }
      await ref.read(appLogProvider).writeAlways(
        'LiveLib',
        result.ok ? 'отметка отправлена' : result.message,
      );
    } catch (error) {
      final message = journalDetail(error);
      await ref.read(appLogProvider).writeAlways('LiveLib', message);
      if (context.mounted) {
        showMessage(context, message);
      }
    } finally {
      account.close();
    }
  }
}
