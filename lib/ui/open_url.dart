import 'package:flutter/material.dart';
import 'package:my_library/core/format/external_url.dart';
import 'package:my_library/ui/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalPage(BuildContext context, String raw) async {
  if (!isAllowedExternalUrl(raw)) {
    showMessage(context, 'Можно открыть только ссылку http или https.');
    return;
  }
  final opened = await launchUrl(
    Uri.parse(raw.trim()),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    showMessage(context, 'Не удалось открыть ссылку.');
  }
}
