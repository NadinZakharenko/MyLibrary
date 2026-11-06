class CatalogRequestRecord {
  const CatalogRequestRecord({
    required this.catalog,
    required this.kind,
    required this.detail,
    this.statusCode,
    this.resultCount = 0,
    this.error,
  });

  final String catalog;
  final String kind;
  final String detail;
  final int? statusCode;
  final int resultCount;
  final String? error;
}

typedef CatalogRequestLog = Future<void> Function(CatalogRequestRecord record);

class ModelCallRecord {
  const ModelCallRecord({
    required this.model,
    this.statusCode,
    this.shelfCount,
    this.bookCount,
    this.error,
  });

  final String model;
  final int? statusCode;
  final int? shelfCount;
  final int? bookCount;
  final String? error;
}

typedef ModelCallLog = Future<void> Function(ModelCallRecord record);
