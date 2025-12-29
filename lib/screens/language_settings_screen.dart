import 'package:flutter/material.dart';

import '../models/app_lang.dart';
import '../services/localizer.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late AppLang _selected;

  @override
  void initState() {
    super.initState();
    _selected = L10n.currentLang;
  }

  void _onChanged(AppLang? value) {
    if (value == null) return;
    setState(() {
      _selected = value;
      L10n.currentLang = value; // ✅ 실제 언어 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.tr('lang.title'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          RadioListTile<AppLang>(
            value: AppLang.ko,
            groupValue: _selected,
            onChanged: _onChanged,
            title: const Text('한국어'),
          ),
          RadioListTile<AppLang>(
            value: AppLang.en,
            groupValue: _selected,
            onChanged: _onChanged,
            title: const Text('English'),
          ),
          RadioListTile<AppLang>(
            value: AppLang.ja,
            groupValue: _selected,
            onChanged: _onChanged,
            title: const Text('日本語'),
          ),
          RadioListTile<AppLang>(
            value: AppLang.zh,
            groupValue: _selected,
            onChanged: _onChanged,
            title: const Text('中文'),
          ),
        ],
      ),
    );
  }
}
