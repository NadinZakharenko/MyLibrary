import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:my_library/core/isbn.dart';
import 'package:my_library/core/logging/catalog_request.dart';
import 'package:my_library/core/logging/redact.dart';
import 'package:my_library/core/metadata/livelib.dart';
import 'package:my_library/core/metadata/rsl.dart';
import 'package:my_library/core/models/book_copy.dart';
import 'package:my_library/core/models/metadata_candidate.dart';
import 'package:my_library/data/yandex_books_client.dart';

class MetadataLookupException implements Exception {
  MetadataLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef ModelTextLookup = Future<List<MetadataCandidate>> Function({
  String? isbn,
  String? title,
  String? author,
});

class MetadataService {
  MetadataService({http.Client? client, this.log, this.model, this.yandexToken})
    : _client = client ?? http.Client();

  final http.Client _client;
  final CatalogRequestLog? log;
  final ModelTextLookup? model;
  final Future<String?> Function()? yandexToken;

  static const userAgent = 'MyLibrary/1.0 (personal home library)';

  /// Edition pages opened per search to read an ISBN the result list omits.
  static const _liveLibEditionPages = 3;

  Future<List<MetadataCandidate>> search({
    String? query,
    String? title,
    String? author,
    String? isbn,
    BookFormat format = BookFormat.print,
  }) async {
    final normalizedIsbn = _cleanIsbn(isbn);
    final titleText = title?.trim().isNotEmpty == true
        ? title!.trim()
        : (query?.trim() ?? '');
    final authorText = author?.trim() ?? '';
    final hasIsbn = normalizedIsbn != null && normalizedIsbn.isNotEmpty;
    final hasText = titleText.isNotEmpty || authorText.isNotEmpty;
    if (!hasIsbn && !hasText) {
      return const [];
    }
    final yandexSecret = (await yandexToken?.call())?.trim() ?? '';
    final secrets = <String>[if (yandexSecret.length >= 6) yandexSecret];

    final results = <MetadataCandidate>[];
    var reachedCatalog = false;
    Object? lastError;
    Future<List<MetadataCandidate>> firstHit(
      List<Future<List<MetadataCandidate>> Function()> steps,
    ) async {
      for (final step in steps) {
        try {
          final found = await step();
          reachedCatalog = true;
          if (found.isNotEmpty) {
            return found;
          }
        } catch (error) {
          lastError = error;
        }
      }
      return const [];
    }

    if (hasIsbn) {
      results.addAll(
        await firstHit([
          () => _rsl(isbn: normalizedIsbn, secrets: secrets),
          () => _liveLib(
            query: normalizedIsbn,
            isbn: normalizedIsbn,
            kind: 'ISBN',
            detail: normalizedIsbn,
            secrets: secrets,
          ),
          if (yandexSecret.isNotEmpty)
            () => _yandex(
              query: normalizedIsbn,
              token: yandexSecret,
              kind: 'ISBN',
              detail: normalizedIsbn,
              secrets: secrets,
              format: format,
            ),
        ]),
      );
    }
    if (results.isEmpty && hasText) {
      final liveQuery = [
        titleText,
        authorText,
      ].where((part) => part.isNotEmpty).join(' ');
      results.addAll(
        await firstHit([
          () => _rsl(title: titleText, author: authorText, secrets: secrets),
          () => _liveLib(
            query: liveQuery,
            kind: _kind(title: titleText, author: authorText),
            detail: _detail(title: titleText, author: authorText),
            secrets: secrets,
          ),
          if (yandexSecret.isNotEmpty)
            () => _yandex(
              query: liveQuery,
              token: yandexSecret,
              kind: _kind(title: titleText, author: authorText),
              detail: _detail(title: titleText, author: authorText),
              secrets: secrets,
              format: format,
            ),
        ]),
      );
    }
    final lookup = model;
    if (results.isEmpty && lookup != null && (hasIsbn || hasText)) {
      try {
        final found = await lookup(
          isbn: normalizedIsbn,
          title: titleText,
          author: authorText,
        );
        if (found.isNotEmpty) {
          return _unique(found);
        }
      } catch (error) {
        lastError = error;
      }
    }

    final failure = lastError;
    if (results.isEmpty && !reachedCatalog && failure != null) {
      if (failure is MetadataLookupException) {
        throw failure;
      }
      throw MetadataLookupException('Не удалось связаться с каталогами книг.');
    }
    return _unique(results);
  }

  List<MetadataCandidate> _unique(List<MetadataCandidate> candidates) {
    final seen = <String>{};
    final unique = <MetadataCandidate>[];
    for (final candidate in candidates) {
      final isbn = candidate.isbn.trim();
      final title = candidate.title.trim().toLowerCase();
      final key = isbn.isNotEmpty
          ? 'isbn:$isbn|$title'
          : 'title:$title|${candidate.authors.join(',').toLowerCase()}';
      if (seen.add(key)) {
        unique.add(candidate);
      }
    }
    return unique;
  }

  Future<Uint8List?> download(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: const {'User-Agent': userAgent})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || response.bodyBytes.length < 64) {
        return null;
      }
      final type = response.headers['content-type'] ?? '';
      if (type.contains('text/html') || type.contains('application/json')) {
        return null;
      }
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  void close() => _client.close();

  Future<List<MetadataCandidate>> _yandex({
    required String query,
    required String token,
    required String kind,
    required String detail,
    required List<String> secrets,
    required BookFormat format,
  }) async {
    try {
      final hits = await YandexBooksClient(httpClient: _client)
          .searchBooks(token: token, query: query);
      final audio = switch (format) {
        BookFormat.print => false,
        BookFormat.audio => true,
      };
      final matched = [
        for (final hit in hits)
          if (hit.audio == audio) hit,
      ];
      await _record(
        catalog: 'Яндекс Книги',
        kind: kind,
        detail: detail,
        secrets: secrets,
        statusCode: 200,
        resultCount: matched.length,
      );
      return [
        for (final hit in matched)
          MetadataCandidate(
            source: MetadataSource.yandexBooks,
            title: hit.title,
            authors: hit.authors,
            publisher: hit.publisher,
            description: hit.annotation,
            narrator: hit.narrator,
            coverUrl: hit.coverUrl,
            sourceUrl: hit.audio
                ? yandexAudiobookUrl(hit.id)
                : yandexBookUrl(hit.id),
            workKey: hit.id,
          ),
      ];
    } catch (error) {
      await _record(
        catalog: 'Яндекс Книги',
        kind: kind,
        detail: detail,
        secrets: secrets,
        error: error is StateError
            ? error.message
            : error is FormatException
            ? 'непонятный ответ'
            : 'нет связи',
      );
      return const [];
    }
  }

  Future<List<MetadataCandidate>> _rsl({
    String? isbn,
    String title = '',
    String author = '',
    required List<String> secrets,
  }) async {
    final params = <String, String>{'server': 'RSL', 'records': '8'};
    if (isbn != null && isbn.isNotEmpty) {
      params['ISBN'] = rslIsbn(isbn) ?? isbn;
    } else {
      final titleQuery = rslTextQuery(title);
      final authorQuery = rslTextQuery(author);
      if (titleQuery.isNotEmpty) {
        params['Title'] = titleQuery;
      }
      if (authorQuery.isNotEmpty) {
        params['Autor'] = authorQuery;
      }
    }
    final kind = _kind(isbn: isbn, title: title, author: author);
    final detail = _detail(isbn: isbn, title: title, author: author);
    final uri = Uri.http(rslGateway, '/bib4md5/zg/zg.php', params);
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent': userAgent,
              'Accept': 'application/xml, text/xml',
            },
          )
          .timeout(const Duration(seconds: 20));
      final body = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
      if (response.statusCode != 200 || !body.startsWith('<')) {
        final note = body.startsWith('<')
            ? 'код ${response.statusCode}'
            : _clip(body.isEmpty ? 'код ${response.statusCode}' : body);
        await _record(
          catalog: 'РГБ',
          kind: kind,
          detail: detail,
          secrets: secrets,
          statusCode: response.statusCode,
          error: note,
        );
        return const [];
      }
      final parsed = candidatesFromRsl(body);
      await _record(
        catalog: 'РГБ',
        kind: kind,
        detail: detail,
        secrets: secrets,
        statusCode: response.statusCode,
        resultCount: parsed.length,
      );
      return parsed;
    } catch (error) {
      await _record(
        catalog: 'РГБ',
        kind: kind,
        detail: detail,
        secrets: secrets,
        error: error is FormatException ? 'непонятный ответ' : 'нет связи',
      );
      rethrow;
    }
  }

  Future<List<MetadataCandidate>> _liveLibEditionIsbns(
    List<MetadataCandidate> candidates,
  ) async {
    if (candidates.isEmpty ||
        candidates.every((item) => item.isbn.trim().isNotEmpty)) {
      return candidates;
    }
    var pages = 0;
    return Future.wait(
      candidates.map((candidate) async {
        if (candidate.isbn.trim().isNotEmpty ||
            pages >= _liveLibEditionPages) {
          return candidate;
        }
        pages++;
        final page = candidate.sourceUrl?.trim() ?? '';
        if (page.isEmpty) {
          return candidate;
        }
        try {
          final response = await _client
              .get(
                Uri.parse(page),
                headers: const {'User-Agent': userAgent, 'Accept': 'text/html'},
              )
              .timeout(const Duration(seconds: 15));
          if (response.statusCode != 200) {
            return candidate;
          }
          final isbn = liveLibPageIsbn(
            utf8.decode(response.bodyBytes, allowMalformed: true),
          );
          if (isbn.isEmpty) {
            return candidate;
          }
          return candidate.copyWith(isbn: isbn);
        } catch (_) {
          return candidate;
        }
      }),
    );
  }

  Future<List<MetadataCandidate>> _liveLib({
    required String query,
    required String kind,
    required String detail,
    String isbn = '',
    required List<String> secrets,
  }) async {
    final uri = liveLibSearchUri(query);
    try {
      final response = await _client
          .get(
            uri,
            headers: const {'User-Agent': userAgent, 'Accept': 'text/html'},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        await _record(
          catalog: 'LiveLib',
          kind: kind,
          detail: detail,
          secrets: secrets,
          statusCode: response.statusCode,
          error: 'код ${response.statusCode}',
        );
        return const [];
      }
      final html = utf8.decode(response.bodyBytes, allowMalformed: true);
      final parsed = await _liveLibEditionIsbns(
        candidatesFromLiveLib(html, isbn: isbn),
      );
      await _record(
        catalog: 'LiveLib',
        kind: kind,
        detail: detail,
        secrets: secrets,
        statusCode: response.statusCode,
        resultCount: parsed.length,
      );
      return parsed;
    } catch (error) {
      await _record(
        catalog: 'LiveLib',
        kind: kind,
        detail: detail,
        secrets: secrets,
        error: error is FormatException ? 'непонятный ответ' : 'нет связи',
      );
      return const [];
    }
  }

  Future<void> _record({
    required String catalog,
    required String kind,
    required String detail,
    required List<String> secrets,
    int? statusCode,
    int resultCount = 0,
    String? error,
  }) async {
    final sink = log;
    if (sink == null) {
      return;
    }
    await sink(
      CatalogRequestRecord(
        catalog: catalog,
        kind: kind,
        detail: redactSecrets(detail, secrets),
        statusCode: statusCode,
        resultCount: resultCount,
        error: error == null ? null : redactSecrets(error, secrets),
      ),
    );
  }

  String? _cleanIsbn(String? isbn) {
    final trimmed = isbn?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return normalizeIsbn(trimmed) ?? trimmed;
  }

  String _kind({String? isbn, String title = '', String author = ''}) {
    if (isbn != null && isbn.isNotEmpty) {
      return 'ISBN';
    }
    if (title.isNotEmpty && author.isNotEmpty) {
      return 'название и автор';
    }
    if (title.isNotEmpty) {
      return 'название';
    }
    if (author.isNotEmpty) {
      return 'автор';
    }
    return 'запрос';
  }

  String _detail({
    String? isbn,
    String title = '',
    String author = '',
    String free = '',
  }) {
    if (isbn != null && isbn.isNotEmpty) {
      return isbn;
    }
    final parts = <String>[
      if (title.isNotEmpty) title,
      if (author.isNotEmpty) author,
      if (title.isEmpty && author.isEmpty) free,
    ];
    return parts.join(' · ');
  }

  String _clip(String value) {
    final flat = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= 120) {
      return flat;
    }
    return flat.substring(0, 120);
  }
}
