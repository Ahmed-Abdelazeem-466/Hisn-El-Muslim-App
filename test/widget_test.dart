import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisn_almuslim_flutter/controllers/app_controller.dart';
import 'package:hisn_almuslim_flutter/data/book_repository.dart';
import 'package:hisn_almuslim_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('starts the Arabic index and displays book categories', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final content = File('assets/data/hisn-book.json').readAsStringSync();
    final repository = BookRepository.fromJson(content);
    final controller = await AppController.load();

    await tester.pumpWidget(
      HisnApp(repository: repository, controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text('حصن المسلم'), findsOneWidget);
    expect(find.text('أذكار يومية'), findsOneWidget);
    expect(find.text('جميع الأقسام'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('الليلة'), findsOneWidget);
    expect(find.text('اليوم والليلة'), findsNothing);
  });
}
