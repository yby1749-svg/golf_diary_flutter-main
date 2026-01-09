// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/app_settings.dart';
import 'models/recent_rounds_store.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 저장된 라운드 데이터 미리 로드
  final roundsStore = RecentRoundsStore();
  await roundsStore.load();

  runApp(GolfDiaryRoot(roundsStore: roundsStore));
}

class GolfDiaryRoot extends StatelessWidget {
  final RecentRoundsStore roundsStore;

  const GolfDiaryRoot({super.key, required this.roundsStore});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider.value(value: roundsStore),
      ],
      child: const GolfDiaryApp(),
    );
  }
}

class GolfDiaryApp extends StatelessWidget {
  const GolfDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Golf Diary',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7D32),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          locale: settings.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
            Locale('ja'),
            Locale('zh'),
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
