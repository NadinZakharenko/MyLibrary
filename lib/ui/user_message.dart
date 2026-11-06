import 'package:my_library/data/backup_service.dart';
import 'package:my_library/data/library_repository.dart';
import 'package:my_library/data/metadata_service.dart';

String userFacingError(Object error) {
  if (error is ChooseRowException) {
    return 'На этой полке несколько рядов. Выберите ряд.';
  }
  if (error is MetadataLookupException) {
    return error.message;
  }
  if (error is BackupException) {
    return error.message;
  }
  if (error is ArgumentError) {
    final message = error.message;
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
  }
  if (error is StateError && error.message.trim().isNotEmpty) {
    return error.message.trim();
  }
  return 'Не получилось выполнить действие. Попробуйте ещё раз.';
}
