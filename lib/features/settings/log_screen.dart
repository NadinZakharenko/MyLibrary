import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  String _text = '';
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final text = await ref.read(appLogProvider).readText();
    if (!mounted) {
      return;
    }
    setState(() {
      _text = text.trim();
      _ready = true;
    });
  }

  Future<void> _clear() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Очистить журнал',
      message: 'Записи действий будут удалены с этого телефона.',
      confirmLabel: 'Очистить',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(appLogProvider).clear();
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Очистить',
            onPressed: _text.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : _text.isEmpty
          ? const EmptyState(
              icon: Icons.notes_outlined,
              title: 'Журнал пуст',
              message:
                  'Включите «Вести журнал» в настройках. Новые действия появятся здесь.',
            )
          : Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(_text),
              ),
            ),
    );
  }
}
