import 'package:flutter/material.dart';
import 'package:my_library/core/models/metadata_candidate.dart';

Future<MetadataCandidate?> chooseMetadataCandidate(
  BuildContext context,
  List<MetadataCandidate> results,
) {
  return showModalBottomSheet<MetadataCandidate>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        children: [
          const ListTile(title: Text('Выберите издание')),
          for (final candidate in results)
            MetadataCandidateTile(
              candidate: candidate,
              onTap: () => Navigator.pop(context, candidate),
            ),
        ],
      ),
    ),
  );
}

/// One edition row: cover, title, authors, publisher, and year.
class MetadataCandidateTile extends StatefulWidget {
  const MetadataCandidateTile({super.key, required this.candidate, this.onTap});

  final MetadataCandidate candidate;
  final VoidCallback? onTap;

  @override
  State<MetadataCandidateTile> createState() => _MetadataCandidateTileState();
}

class _MetadataCandidateTileState extends State<MetadataCandidateTile> {
  var _coverFailed = false;

  @override
  void didUpdateWidget(MetadataCandidateTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidate.coverUrl != widget.candidate.coverUrl) {
      _coverFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final coverUrl = candidate.coverUrl?.trim() ?? '';
    final showCover = coverUrl.isNotEmpty && !_coverFailed;
    final lines = _editionLines(candidate);
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCover) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  coverUrl,
                  width: 48,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    _hideCover();
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate.title, style: theme.textTheme.titleMedium),
                  if (lines.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      lines.join('\n'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideCover() {
    if (_coverFailed) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_coverFailed) {
        setState(() => _coverFailed = true);
      }
    });
  }
}

/// Publisher name and year for an edition row.
///
/// When [MetadataCandidate.publisher] ends with ", YYYY" and that year is
/// [MetadataCandidate.year], the name is shown without the repeated year.
({String publisher, String year}) editionListText(MetadataCandidate candidate) {
  final year = candidate.year.trim();
  var publisher = candidate.publisher.trim();
  final trailing = RegExp(r',\s*(\d{4})$').firstMatch(publisher);
  if (trailing != null && trailing.group(1) == year) {
    publisher = publisher.substring(0, trailing.start).trim();
  }
  if (year.isNotEmpty && publisher == year) {
    publisher = '';
  }
  return (publisher: publisher, year: year);
}

List<String> _editionLines(MetadataCandidate candidate) {
  final edition = editionListText(candidate);
  return [
    candidate.authors.join(', '),
    if (candidate.isbn.isNotEmpty) candidate.isbn,
    if (edition.publisher.isNotEmpty) edition.publisher,
    if (edition.year.isNotEmpty) edition.year,
  ].where((part) => part.isNotEmpty).toList();
}
