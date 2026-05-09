import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fastadb/main.dart';

void main() {
  testWidgets('FastADB app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FastADBApp()));
    expect(find.text('FastADB'), findsWidgets);
  });
}
