import 'dart:io';

import 'package:flutter/foundation.dart';

bool get deviceCaptureSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
