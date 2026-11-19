import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/user_message.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить данные',
        message: userFacingError(error),
        actionLabel: onRetry == null ? null : 'Повторить',
        onAction: onRetry,
      ),
    );
  }
}

class CoverImage extends ConsumerWidget {
  const CoverImage({
    super.key,
    this.relativePath,
    this.width = 56,
    this.height = 84,
    this.borderRadius = 8,
  });

  final String? relativePath;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = relativePath;
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book_outlined, color: scheme.primary),
    );
    Widget child = placeholder;
    if (path != null && path.isNotEmpty) {
      final file = ref.watch(imageStoreProvider).resolve(path);
      if (file != null) {
        final pixels = MediaQuery.devicePixelRatioOf(context);
        final side = width > height ? width : height;
        child = Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: (side * pixels).round(),
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class BookSummaryTile extends StatelessWidget {
  const BookSummaryTile({
    super.key,
    required this.title,
    required this.authors,
    required this.genres,
    required this.location,
    this.coverPath,
    this.notes = const [],
    this.onTap,
    this.onLocationTap,
    this.selecting = false,
    this.selected = false,
  });

  final String title;
  final String authors;
  final String genres;
  final String location;
  final String? coverPath;
  final List<String> notes;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTap;
  final bool selecting;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = [
      if (authors.isNotEmpty) authors else 'Автор не указан',
      if (genres.isNotEmpty) genres,
      ...notes,
    ];
    return ListTile(
      onTap: onTap,
      leading: CoverImage(relativePath: coverPath),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lines.isNotEmpty) Text(lines.join('\n'), style: theme.textTheme.bodyMedium),
          if (onLocationTap == null)
            Text(location, style: theme.textTheme.bodyMedium)
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onLocationTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(location),
              ),
            ),
        ],
      ),
      isThreeLine: true,
      trailing: selecting
          ? Icon(selected ? Icons.check_circle : Icons.circle_outlined)
          : null,
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Удалить',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
