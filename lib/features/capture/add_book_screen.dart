import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/core/models/book_draft.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/platform_support.dart';
import 'package:my_library/features/capture/capture_controller.dart';
import 'package:my_library/features/capture/capture_navigation.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

class AddBookScreen extends ConsumerWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(captureControllerProvider);
    final photos = shelfModelReadsPhotos(
      ref.watch(shelfModelChoiceProvider).asData?.value ?? ShelfModelChoice.off,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить книгу'),
        actions: [
          if (capture.drafts.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(captureControllerProvider.notifier).reset(),
              child: const Text('Заново'),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Как найти книгу? Совпадения из каталогов не сохраняются сами: сначала список вариантов, потом карточка, которую можно поправить.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _MethodCard(
                icon: Icons.qr_code_scanner,
                title: captureMethodTitle(CaptureMethod.barcode),
                subtitle: 'ISBN-10 или ISBN-13 с камеры',
                onTap: () => _barcode(context, ref),
              ),
              if (photos)
                _MethodCard(
                  icon: Icons.photo_camera_outlined,
                  title: captureMethodTitle(CaptureMethod.singlePhoto),
                  subtitle: 'Обложка, корешок или титульный лист',
                  onTap: () => _photo(context, ref),
                ),
              if (photos)
                _MethodCard(
                  icon: Icons.photo_library_outlined,
                  title: captureMethodTitle(CaptureMethod.batchPhotos),
                  subtitle: 'Несколько снимков, у каждого своя карточка',
                  onTap: () => _batch(context, ref),
                ),
              _MethodCard(
                icon: Icons.keyboard_outlined,
                title: captureMethodTitle(CaptureMethod.manual),
                subtitle: 'Название и, если знаете, автор',
                onTap: () => context.push('/add/manual'),
              ),
              if (photos)
                _MethodCard(
                  icon: Icons.view_column_outlined,
                  title: 'Полка целиком',
                  subtitle: 'Выбранная в настройках модель читает корешки.',
                  onTap: () => context.push('/add/shelf'),
                ),
            ],
          ),
          if (capture.busy)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _barcode(BuildContext context, WidgetRef ref) async {
    if (!deviceCaptureSupported) {
      showMessage(
        context,
        'Сканер ISBN доступен на телефоне. Название можно ввести вручную.',
      );
      return;
    }
    final raw = await context.push<String>('/scan');
    if (raw == null || !context.mounted) {
      return;
    }
    final next = await ref
        .read(captureControllerProvider.notifier)
        .consumeBarcode(raw);
    if (!context.mounted) {
      return;
    }
    await openCaptureNext(context, ref, next);
  }

  Future<void> _photo(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Выбрать фото'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) {
      return;
    }
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (file == null || !context.mounted) {
        return;
      }
      final next = await ref
          .read(captureControllerProvider.notifier)
          .consumePhoto(file.path);
      if (!context.mounted) {
        return;
      }
      await openCaptureNext(context, ref, next);
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Не удалось открыть фото.');
      }
    }
  }

  Future<void> _batch(BuildContext context, WidgetRef ref) async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (files.isEmpty || !context.mounted) {
        return;
      }
      final next = await ref
          .read(captureControllerProvider.notifier)
          .consumeBatch([for (final file in files) file.path]);
      if (!context.mounted) {
        return;
      }
      await openCaptureNext(context, ref, next);
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Не удалось выбрать фотографии.');
      }
    }
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        minVerticalPadding: 16,
        onTap: onTap,
      ),
    );
  }
}
