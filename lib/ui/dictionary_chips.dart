import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/format/hashtag.dart';
import 'package:my_library/core/models/dictionary_kind.dart';
import 'package:my_library/providers/app_providers.dart';

class DictionaryChips extends ConsumerStatefulWidget {
  const DictionaryChips({
    super.key,
    required this.kind,
    required this.label,
    required this.values,
    required this.onChanged,
    this.hint,
  });

  final DictionaryKind kind;
  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String? hint;

  @override
  ConsumerState<DictionaryChips> createState() => _DictionaryChipsState();
}

class _DictionaryChipsState extends ConsumerState<DictionaryChips> {
  final _controller = TextEditingController();
  List<String> _suggestions = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh(String text) async {
    final items = await ref
        .read(libraryRepositoryProvider)
        .suggest(widget.kind, text);
    if (!mounted) {
      return;
    }
    setState(() {
      _suggestions = items.where((item) => !_contains(item)).toList();
    });
  }

  bool _contains(String value) {
    if (widget.kind == DictionaryKind.hashtag) {
      final key = normalizeHashtag(value);
      return widget.values.any((item) => normalizeHashtag(item) == key);
    }
    final key = value.trim().toLowerCase();
    return widget.values.any((item) => item.trim().toLowerCase() == key);
  }

  void _add(String raw) {
    final value = switch (widget.kind) {
      DictionaryKind.author ||
      DictionaryKind.genre ||
      DictionaryKind.publisher => raw.trim(),
      DictionaryKind.hashtag => hashtagDisplayName(raw) ?? '',
    };
    if (value.isEmpty || _contains(value)) {
      _controller.clear();
      setState(() => _suggestions = const []);
      return;
    }
    widget.onChanged([...widget.values, value]);
    _controller.clear();
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (widget.values.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in widget.values)
                InputChip(
                  label: Text(
                    widget.kind == DictionaryKind.hashtag ? '#$value' : value,
                  ),
                  onDeleted: () {
                    widget.onChanged([
                      for (final item in widget.values)
                        if (item != value) item,
                    ]);
                  },
                ),
            ],
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Добавить и нажать ввод',
          ),
          textInputAction: TextInputAction.done,
          onChanged: _refresh,
          onSubmitted: _add,
        ),
        if (_suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            children: [
              for (final suggestion in _suggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _add(suggestion),
                ),
            ],
          ),
      ],
    );
  }
}
