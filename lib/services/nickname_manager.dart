import 'package:shared_preferences/shared_preferences.dart';

class NicknameManager {
  static const String _storageKey = 'user_nickname';
  static final NicknameManager instance = NicknameManager._();
  
  NicknameManager._();

  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey);
  }

  Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, nickname);
  }
} 