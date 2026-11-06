import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library/features/library/structure_actions.dart';

void main() {
  testWidgets('canceling a text dialog does not crash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: _OpenCabinetRename()),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Открыть'), findsOneWidget);
  });
}

class _OpenCabinetRename extends ConsumerWidget {
  const _OpenCabinetRename();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => renameCabinetFlow(
        context,
        ref,
        id: 1,
        name: 'Шкаф',
      ),
      child: const Text('Открыть'),
    );
  }
}
