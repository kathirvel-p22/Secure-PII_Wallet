import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:secure_pii_wallet/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SecurePIIWalletApp(),
      ),
    );

    // Verify that splash screen appears
    expect(find.text('SECURE PII WALLET'), findsOneWidget);
  });
}
