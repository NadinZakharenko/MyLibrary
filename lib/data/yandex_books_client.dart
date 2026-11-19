import 'dart:convert';

import 'package:http/http.dart' as http;

class YandexAudiobookRemote {
  const YandexAudiobookRemote({
    required this.id,
    required this.title,
    required this.authors,
    required this.narrators,
    this.durationSeconds,
    this.annotation = '',
    this.coverUrl,
  });

  final String id;
  final String title;
  final List<String> authors;
  final List<String> narrators;
  final int? durationSeconds;
  final String annotation;
  final String? coverUrl;
}

class YandexCatalogHit {
  const YandexCatalogHit({
    required this.id,
    required this.title,
    required this.authors,
    required this.audio,
    this.publisher = '',
    this.annotation = '',
    this.narrator = '',
    this.coverUrl,
  });

  final String id;
  final String title;
  final List<String> authors;
  final bool audio;
  final String publisher;
  final String annotation;
  final String narrator;
  final String? coverUrl;
}

class YandexBooksClient {
  const YandexBooksClient({http.Client? httpClient, this.pageSize = 100})
      : _http = httpClient;

  final http.Client? _http;
  final int pageSize;

  Future<String> profileId({
    required String token,
    String? publicId,
  }) async {
    final stored = publicId?.trim() ?? '';
    if (token.trim().isEmpty) {
      if (stored.isEmpty) {
        throw StateError('Укажите профиль Яндекс Книг.');
      }
      return stored;
    }
    final body = await _get('/profile', token: token);
    final user = body['user'];
    if (user is! Map) {
      throw StateError('Яндекс Книги не вернули профиль.');
    }
    final id = '${user['login'] ?? user['id'] ?? user['uuid'] ?? ''}'.trim();
    if (id.isEmpty) {
      throw StateError('В профиле Яндекс Книг нет идентификатора.');
    }
    return id;
  }

  Future<List<YandexAudiobookRemote>> finishedAudiobooks({
    required String profileId,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      return _shelfAudiobooks(profileId, token);
    }
    final byId = <String, YandexAudiobookRemote>{};
    for (final book in await _shelfAudiobooks(profileId, token, listened: true)) {
      byId[book.id] = book;
    }
    for (final book in await _cardAudiobooks(token)) {
      byId.putIfAbsent(book.id, () => book);
    }
    return byId.values.toList();
  }

  Future<List<YandexAudiobookRemote>> _shelfAudiobooks(
    String profileId,
    String token, {
    bool listened = false,
  }) async {
    final rows = await _pages(
      '/users/${Uri.encodeComponent(profileId)}/audiobooks',
      token,
      const ['audiobooks'],
    );
    return [
      for (final row in rows)
        if (!listened || _finished(row['audio_card'])) _book(row),
    ].where((book) => book.id.isNotEmpty && book.title.isNotEmpty).toList();
  }

  Future<List<YandexAudiobookRemote>> _cardAudiobooks(String token) async {
    final rows = await _pages(
      '/profile/library_cards',
      token,
      const ['library_cards', 'libraryCards'],
    );
    return [
      for (final row in rows)
        if (_finished(row))
          if (_cardAudiobook(row) case final Map<dynamic, dynamic> audio)
            _book(audio),
    ].where((book) => book.id.isNotEmpty && book.title.isNotEmpty).toList();
  }

  Map<dynamic, dynamic>? _cardAudiobook(Map<dynamic, dynamic> card) {
    final audio = card['audiobook'];
    if (audio is Map) {
      return audio;
    }
    final book = card['book'];
    if (book is Map && '${book['resource_type'] ?? book['type']}' == 'audiobook') {
      return book;
    }
    return null;
  }

  bool _finished(Object? value) {
    return value is Map && '${value['state']}'.trim() == 'finished';
  }

  Future<List<Map<dynamic, dynamic>>> _pages(
    String path,
    String token,
    List<String> keys,
  ) async {
    final rows = <Map<dynamic, dynamic>>[];
    for (var page = 1; page <= 50; page++) {
      final body = await _get(
        path,
        token: token,
        query: {'page': '$page', 'per_page': '$pageSize'},
      );
      final chunk = _chunk(body, keys);
      if (chunk.isEmpty) {
        break;
      }
      rows.addAll(chunk);
      if (chunk.length < pageSize) {
        break;
      }
    }
    return rows;
  }

  List<Map<dynamic, dynamic>> _chunk(
    Map<String, Object?> body,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = body[key];
      if (value is List) {
        return [for (final row in value) if (row is Map) row];
      }
    }
    return const [];
  }

  YandexAudiobookRemote _book(Map<dynamic, dynamic> row) {
    final cover = row['cover'];
    String? coverUrl;
    if (cover is String && cover.startsWith('http')) {
      coverUrl = cover;
    } else if (cover is Map) {
      final candidate = cover['large'] ?? cover['small'] ?? cover['url'];
      if (candidate is String && candidate.startsWith('http')) {
        coverUrl = candidate;
      }
    }
    final duration = row['duration'];
    return YandexAudiobookRemote(
      id: '${row['uuid'] ?? row['id'] ?? ''}'.trim(),
      title: '${row['title'] ?? row['name'] ?? ''}'.trim(),
      authors: _names(row['authors']),
      narrators: _names(row['narrators']),
      durationSeconds: duration is int ? duration : int.tryParse('$duration'),
      annotation: '${row['annotation'] ?? row['description'] ?? ''}'.trim(),
      coverUrl: coverUrl,
    );
  }

  List<String> _names(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    if (value is! List) {
      return const [];
    }
    return [
      for (final item in value)
        if (item is Map && '${item['name'] ?? ''}'.trim().isNotEmpty)
          '${item['name']}'.trim(),
    ];
  }

  Future<Map<String, Object?>> _get(
    String path, {
    required String token,
    Map<String, String>? query,
  }) async {
    final uri = Uri.https('api.bookmate.yandex.net', '/api/v5$path', query);
    final secret = token.trim();
    final headers = <String, String>{
      'App-Language': 'ru',
      'App-Locale': 'ru',
      'App-Platform': 'android',
      'Bookmate-Version': '20200305',
      'Device-Os': 'Android',
      'User-Agent': 'okhttp/4.12.0',
      if (secret.isNotEmpty) 'Auth-Token': secret,
    };
    final client = _http;
    final response = await (client == null
            ? http.get(uri, headers: headers)
            : client.get(uri, headers: headers))
        .timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final reason = response.statusCode == 401
          ? ' Токен не принят. Нужен OAuth-токен Яндекс Книг.'
          : '';
      throw StateError('Яндекс Книги ответили ${response.statusCode}.$reason');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }

  Future<List<YandexCatalogHit>> searchBooks({
    required String token,
    required String query,
  }) async {
    final secret = token.trim();
    final text = query.trim();
    if (secret.isEmpty || text.isEmpty) {
      return const [];
    }
    final uri = Uri.https('api-gateway.bookmate.yandex.net', '/graphql');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'App-Language': 'ru',
      'App-Locale': 'ru',
      'App-Platform': 'android',
      'Bookmate-Version': '20200305',
      'Device-Os': 'Android',
      'User-Agent': 'okhttp/4.12.0',
      'Auth-Token': secret,
    };
    final payload = jsonEncode({
      'operationName': 'Search',
      'variables': {
        'query': {
          'cursor': '',
          'noMisspell': false,
          'query': text,
          'types': <String>[],
        },
      },
      'query': _yandexSearchQuery,
    });
    final client = _http;
    final response = await (client == null
            ? http.post(uri, headers: headers, body: payload)
            : client.post(uri, headers: headers, body: payload))
        .timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final reason = response.statusCode == 401
          ? ' Токен не принят. Нужен OAuth-токен Яндекс Книг.'
          : '';
      throw StateError('Яндекс Книги ответили ${response.statusCode}.$reason');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return _catalogHits(decoded);
  }

  List<YandexCatalogHit> _catalogHits(Object? json) {
    if (json is! Map) {
      return const [];
    }
    final data = json['data'];
    if (data is! Map) {
      return const [];
    }
    final search = data['search'];
    if (search is! Map) {
      return const [];
    }
    final page = search['page'];
    if (page is! List) {
      return const [];
    }
    final hits = <YandexCatalogHit>[];
    for (final item in page) {
      if (hits.length == 8) {
        break;
      }
      if (item is! Map) {
        continue;
      }
      final kind = '${item['__typename'] ?? ''}';
      final audio = kind == 'AudioBook';
      if (kind != 'TextBook' && kind != 'TextSerial' && !audio) {
        continue;
      }
      final book = item['book'];
      if (book is! Map) {
        continue;
      }
      final title = '${book['name'] ?? book['title'] ?? ''}'.trim();
      final id = '${book['uuid'] ?? book['id'] ?? ''}'.trim();
      if (title.isEmpty || id.isEmpty) {
        continue;
      }
      final narrators = _names(item['narrators']);
      hits.add(
        YandexCatalogHit(
          id: id,
          title: title,
          authors: _names(book['authors']),
          audio: audio,
          publisher: _publisherName(book['publisher']),
          annotation: _plain('${book['annotation'] ?? book['editorAnnotation'] ?? ''}'),
          narrator: narrators.join(', '),
          coverUrl: _coverUrl(book['cover']),
        ),
      );
    }
    return hits;
  }

  String _publisherName(Object? value) {
    if (value is Map) {
      return '${value['name'] ?? ''}'.trim();
    }
    if (value is String) {
      return value.trim();
    }
    return '';
  }

  String? _coverUrl(Object? value) {
    if (value is String && value.startsWith('http')) {
      return value;
    }
    if (value is Map) {
      final candidate = value['url'] ?? value['large'] ?? value['small'];
      if (candidate is String && candidate.startsWith('http')) {
        return candidate;
      }
    }
    return null;
  }

  String _plain(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

const _requestTimeout = Duration(seconds: 20);

const _yandexSearchQuery = r'''
query Search($query: SearchParamsInput!) {
    search(query: $query) {
        page {
            __typename
            ...searchSnippetAudioBookFragment
            ...searchSnippetTextBookFragment
            ...searchSnippetComicBookFragment
            ...searchSnippetTextSerialFragment
            ...bookshelfFragment
            ...personFragment
            ...publisherFragment
            ...seriesFragment
            ...topicFragment
            ...userFragment
        }
        cursor
        rankedFilter { filterType }
        misspell { correctedText correctionType }
    }
}
fragment coverFragment on Cover { url ratio backgroundColorHex }
fragment personFragment on Person { avatar { __typename ...coverFragment } name uuid worksCount roles }
fragment bookFragment on Book { annotation name cover { __typename ...coverFragment } uuid authors { __typename ...personFragment } ageRestriction editorAnnotation }
fragment publisherFragment on Publisher { avatar { __typename ...coverFragment } name uuid worksCount }
fragment publisherBookFragment on Book { publisher { __typename ...publisherFragment } }
fragment translatorsBookFragment on Book { translators { __typename ...personFragment } }
fragment topicsBookFragment on Book { topics { name totalBook uuid } }
fragment subscriptionLevelsFragment on Book { subscriptionLevels }
fragment snippetBookFragment on Book { __typename ...bookFragment ...publisherBookFragment ...translatorsBookFragment ...topicsBookFragment ...subscriptionLevelsFragment }
fragment bookTagFragment on Tag { name value }
fragment narratorsAudioBookFragment on AudioBook { narrators { __typename ...personFragment } }
fragment progressFragment on Progress { finished inLibrary progress isPublic }
fragment progressAudioBookFragment on AudioBook { progress { __typename ...progressFragment } }
fragment listenersCountAudioBookFragment on AudioBook { listenersCount }
fragment searchSnippetAudioBookFragment on AudioBook { __typename book { __typename ...snippetBookFragment tags { __typename ...bookTagFragment } } ...narratorsAudioBookFragment ...progressAudioBookFragment ...listenersCountAudioBookFragment }
fragment progressTextBookFragment on TextBook { progress { __typename ...progressFragment } }
fragment readersCountTextBookFragment on TextBook { readersCount }
fragment searchSnippetTextBookFragment on TextBook { __typename book { __typename ...snippetBookFragment tags { __typename ...bookTagFragment } } ...progressTextBookFragment ...readersCountTextBookFragment }
fragment progressComicBookFragment on ComicBook { progress { __typename ...progressFragment } }
fragment readersCountComicBookFragment on ComicBook { readersCount }
fragment searchSnippetComicBookFragment on ComicBook { __typename book { __typename ...snippetBookFragment tags { __typename ...bookTagFragment } } ...progressComicBookFragment ...readersCountComicBookFragment }
fragment textSerialFragment on TextSerial { book { __typename ...bookFragment } }
fragment episodesTextSerialFragment on TextSerial { episodes { total } }
fragment readersCountTextSerialFragment on TextSerial { readersCount }
fragment searchSnippetTextSerialFragment on TextSerial { __typename book { __typename ...snippetBookFragment tags { __typename ...bookTagFragment } } ...textSerialFragment ...episodesTextSerialFragment ...readersCountTextSerialFragment }
fragment userFragment on User { avatar { __typename ...coverFragment } name uuid followersCount login }
fragment bookshelfFragment on Bookshelf { cover { __typename ...coverFragment } name uuid user { __typename ...userFragment } posts { total } followersCount description }
fragment seriesFragment on Series { authors { __typename ...personFragment } cover { __typename ...coverFragment } name uuid items { followersCount total } }
fragment topicFragment on Topic { name slug totalBook uuid parent { name slug totalBook uuid } }
''';
