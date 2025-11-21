// lib/models/recent_rounds_store.dart
//
// 최근 라운드 리스트를 메모리 + SharedPreferences 에 저장/로드

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'round.dart';

class RecentRoundsStore extends ChangeNotifier {
  static const _prefsKey = 'recent_rounds_v1';

  List<Round> _rounds = [];

  List<Round> get rounds => List.unmodifiable(_rounds);

  // 앱 시작 시 호출
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      _rounds = [];
      notifyListeners();
      return;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      _rounds = list
          .whereType<Map<String, dynamic>>()
          .map((m) => Round.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      _rounds = [];
    }

    notifyListeners();
  }

  Future<void> add(Round round) async {
    _rounds.insert(0, round); // 최신 라운드가 위로
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _rounds.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _rounds.map((r) => r.toMap()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }
}
