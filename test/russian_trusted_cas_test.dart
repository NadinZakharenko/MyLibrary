import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/data/russian_trusted_cas.dart';

void main() {
  test('Russian Trusted CA loads beside the system roots', () {
    final context = russianTrustedSecurityContext();
    expect(context, isNotNull);
  });
}
