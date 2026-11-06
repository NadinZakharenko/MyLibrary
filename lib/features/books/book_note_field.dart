import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_library/core/models/shelf_model.dart';
import 'package:my_library/core/notes/voice_note.dart';
import 'package:my_library/providers/app_providers.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:my_library/ui/user_message.dart';

class BookNoteField extends ConsumerStatefulWidget {
  const BookNoteField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  ConsumerState<BookNoteField> createState() => _BookNoteFieldState();
}

class _BookNoteFieldState extends ConsumerState<BookNoteField> {
  var _listening = false;
  var _recordingClip = false;
  var _formatting = false;
  var _sending = false;
  var _textBefore = '';
  String? _dictated;
  String? _recordingPath;
  String? _notice;

  bool get _busy => _listening || _recordingClip || _formatting || _sending;

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final voiceModel =
        ref.watch(voiceModelChoiceProvider).asData?.value ?? ShelfModelChoice.off;
    final notice = _notice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled && !_listening,
          onChanged: (_) => setState(() {}),
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Заметка',
            helperText: 'Ваша заметка, отдельно от описания',
            suffixIcon: IconButton(
              tooltip: _listening ? 'Остановить' : 'Надиктовать',
              onPressed: !widget.enabled || _formatting || _sending
                  ? null
                  : _toggleMic,
              icon: Icon(
                _listening ? Icons.stop_circle_outlined : Icons.mic_none_outlined,
              ),
            ),
          ),
        ),
        if (_listening) ...[
          const SizedBox(height: 8),
          const Text('Слушаю…'),
        ],
        if (notice != null) ...[
          const SizedBox(height: 8),
          Text(notice),
        ],
        if (_recordingClip) ...[
          const SizedBox(height: 8),
          const Text('Записываю для модели…'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _stopModelClip,
            child: const Text('Остановить запись'),
          ),
        ] else if (_recordingPath != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _sendRecording,
            child: Text(
              _sending ? 'Отправляем запись…' : 'Отправить запись модели',
            ),
          ),
        ] else if (notice == phoneDidNotRecognizeMessage) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _startModelClip,
            child: const Text('Записать для модели'),
          ),
        ],
        if (hasText && voiceModel != ShelfModelChoice.off) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: !widget.enabled || _busy ? null : _format,
            child: Text(
              _formatting ? 'Приводим в порядок…' : 'Привести в порядок',
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _toggleMic() async {
    final recognizer = ref.read(phoneRecognizerProvider);
    if (_listening) {
      await recognizer.stop();
      return;
    }
    setState(() {
      _listening = true;
      _notice = null;
      _recordingPath = null;
    });
    try {
      final captured = await capturePhoneNote(
        recognizer: recognizer,
        log: _speechLog,
      );
      if (!mounted) {
        return;
      }
      final transcript = captured.transcript.trim();
      if (transcript.isNotEmpty) {
        _textBefore = widget.controller.text;
        _dictated = transcript;
        widget.controller.text = appendBookNote(_textBefore, transcript);
        widget.controller.selection = TextSelection.collapsed(
          offset: widget.controller.text.length,
        );
        setState(() {
          _recordingPath = null;
          _notice = null;
        });
        return;
      }
      final error = captured.error;
      setState(() {
        _recordingPath = captured.recordingPath;
        _notice = captured.recordingPath == null && error != null
            ? userFacingError(error)
            : phoneDidNotRecognizeMessage;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _notice = userFacingError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _listening = false);
      }
    }
  }

  void _speechLog(String detail) {
    ref.read(appLogProvider).writeAlways('Распознавание речи', detail);
  }

  Future<void> _startModelClip() async {
    setState(() => _notice = null);
    try {
      await startNoteClip(
        recorder: ref.read(noteRecorderProvider),
        log: _speechLog,
      );
      if (mounted) {
        setState(() => _recordingClip = true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _notice = userFacingError(error));
      }
    }
  }

  Future<void> _stopModelClip() async {
    final path = await stopNoteClip(
      recorder: ref.read(noteRecorderProvider),
      log: _speechLog,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _recordingClip = false;
      _recordingPath = path;
      _notice = path == null ? 'Запись не сохранилась.' : null;
    });
  }

  Future<void> _format() async {
    setState(() => _formatting = true);
    try {
      final settings = await ref
          .read(libraryRepositoryProvider)
          .voiceNoteSettings();
      final parts = notePartsForFormat(
        fieldText: widget.controller.text,
        dictated: _dictated,
        textBeforeDictation: _textBefore,
      );
      final result = await formatDictatedNote(
        existing: parts.existing,
        transcript: parts.transcript,
        userAsked: true,
        consent: settings.formatConsent,
        modelSelected: settings.modelSelected,
        credentialsReady: settings.credentialsReady,
        format: (text) {
          return ref.read(voiceNoteClientProvider).formatNote(settings, text);
        },
      );
      if (!mounted) {
        return;
      }
      await _apply(result, parts.existing);
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _formatting = false);
      }
    }
  }

  Future<void> _sendRecording() async {
    final path = _recordingPath;
    if (path == null) {
      return;
    }
    setState(() => _sending = true);
    try {
      final settings = await ref
          .read(libraryRepositoryProvider)
          .voiceNoteSettings();
      final before = widget.controller.text;
      final result = await transcribeRecordingIfAllowed(
        existing: before,
        userAsked: true,
        consent: settings.recordingConsent,
        modelSelected: settings.modelSelected,
        credentialsReady: settings.credentialsReady,
        transcribe: () {
          return ref
              .read(voiceNoteClientProvider)
              .transcribeFile(settings, path);
        },
      );
      if (!mounted) {
        return;
      }
      if (result.sent && result.transcript != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
        if (!mounted) {
          return;
        }
        setState(() => _recordingPath = null);
      }
      await _apply(result, before);
    } catch (error) {
      if (mounted) {
        showMessage(context, userFacingError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _apply(NoteModelResult result, String before) async {
    final message = result.message;
    if (message != null && message.isNotEmpty) {
      await ref.read(appLogProvider).writeAlways('Модель · заметка', message);
    }
    if (!mounted) {
      return;
    }
    if (!result.sent) {
      if (result.message != null && result.message!.isNotEmpty) {
        showMessage(context, result.message!);
      }
      return;
    }
    final transcript = result.transcript;
    if (transcript == null) {
      if (result.message != null) {
        showMessage(context, result.message!);
      }
      return;
    }
    _textBefore = before;
    _dictated = transcript;
    widget.controller.text = result.text;
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    setState(() => _notice = null);
  }
}
