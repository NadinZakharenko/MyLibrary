import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_library/features/capture/capture_controller.dart';
import 'package:my_library/ui/common_widgets.dart';

Future<void> openCaptureNext(
  BuildContext context,
  WidgetRef ref,
  CaptureNext next,
) async {
  if (!context.mounted) {
    return;
  }
  switch (next) {
    case CaptureNext.candidates:
      await context.push('/add/candidates');
    case CaptureNext.form:
      final error = ref.read(captureControllerProvider).error;
      if (error != null && context.mounted) {
        showMessage(context, error);
      }
      if (context.mounted) {
        await context.push('/add/form');
      }
    case CaptureNext.batch:
      await context.push('/add/batch');
    case CaptureNext.rejected:
      final error = ref.read(captureControllerProvider).error;
      if (error != null && context.mounted) {
        showMessage(context, error);
      }
  }
}
