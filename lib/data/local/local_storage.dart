import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper minimo sopra SharedPreferences: salva e legge liste di
/// mappe (JSON) sotto una chiave. Usato dai repository per rendere
/// permanenti categorie e spese (altrimenti si perderebbero ogni volta
/// che chiudi l'app).
class LocalStorage {
  LocalStorage._();
  static SharedPreferences? _prefs;

  static Future<void> ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    await ensureReady();
    await _prefs!.setString(key, jsonEncode(items));
  }

  static List<Map<String, dynamic>> loadList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}
