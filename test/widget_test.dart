import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poweralert_gh_flutter/main.dart';
import 'package:poweralert_gh_flutter/services/storage_service.dart';

void main() {
  testWidgets('App loads with storage', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(MyApp(storageService: storage));
    await tester.pump();

    expect(find.text('PowerAlert GH'), findsOneWidget);
  });
}
