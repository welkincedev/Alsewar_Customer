import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carwashapp/app/app.dart';

void main() {
  testWidgets('App loads splash or login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CarWashApp()));

    expect(find.byType(CarWashApp), findsOneWidget);
  });
}
