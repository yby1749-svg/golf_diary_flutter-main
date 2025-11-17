import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/app_lang.dart';
import '../services/localizer.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('lang.title', lang)),
      ),
      body: ListView(
        children: AppLang.values.map((l) {
          return RadioListTile<AppLang>(
            value: l,
            groupValue: lang,
            title: Text(l.displayName),
            onChanged: (v) {
              if (v != null) {
                context.read<AppSettings>().setLanguage(v);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
