import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ranking_record.dart';

class RankingManager {
  static const String _storageKey = 'ranking_records';
  static final RankingManager instance = RankingManager._();
  
  RankingManager._();

  Future<void> addRecord(RankingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.add(record);
    
    // 난이도별로 최대 10개까지만 저장
    final filteredRecords = _filterTopRecords(records);
    
    await prefs.setString(
      _storageKey,
      jsonEncode(filteredRecords.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<RankingRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_storageKey);
    if (recordsJson == null) return [];

    final List<dynamic> jsonList = jsonDecode(recordsJson);
    return jsonList.map((json) => RankingRecord.fromJson(json)).toList();
  }

  List<RankingRecord> _filterTopRecords(List<RankingRecord> records) {
    final Map<String, List<RankingRecord>> recordsByDifficulty = {};
    
    // 난이도별로 분류
    for (final record in records) {
      recordsByDifficulty[record.difficulty] ??= [];
      recordsByDifficulty[record.difficulty]!.add(record);
    }

    // 각 난이도별로 시간순으로 정렬하고 상위 10개만 유지
    final List<RankingRecord> filteredRecords = [];
    recordsByDifficulty.forEach((_, difficultyRecords) {
      difficultyRecords.sort((a, b) => a.time.compareTo(b.time));
      filteredRecords.addAll(difficultyRecords.take(10));
    });

    return filteredRecords;
  }
} 