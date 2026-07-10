import 'package:flutter_test/flutter_test.dart';

import 'package:super_mario_mobile/app.dart';

void main() {
  testWidgets('App boots to splash', (tester) async {
    await tester.pumpWidget(const MarioApp());
    expect(find.textContaining('SUPER'), findsWidgets);
  });
}
