// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/app_settings.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GolfDiaryApp());
}

class GolfDiaryApp extends StatelessWidget {
  const GolfDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),

      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, _) {
          // lang 값이 바뀌면 전체 앱을 다시 그리도록 의도적으로 읽어줌
          final _ = settings.lang;

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

            // ✅ 머티리얼 기본 문자열(뒤로가기 버튼 등) 로컬라이제이션
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

            // ✅ 앱 첫 화면
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
