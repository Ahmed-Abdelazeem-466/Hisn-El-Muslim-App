import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_theme.dart';
import 'controllers/app_controller.dart';
import 'data/book_repository.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await BookRepository.load();
  final controller = await AppController.load();
  runApp(HisnApp(repository: repository, controller: controller));
}

class HisnApp extends StatelessWidget {
  const HisnApp({
    super.key,
    required this.repository,
    required this.controller,
  });

  final BookRepository repository;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'حصن المسلم',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.themeMode,
          home: HomeShell(repository: repository, controller: controller),
        );
      },
    );
  }
}
