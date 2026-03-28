import 'package:shared_preferences/shared_preferences.dart';

/// App preferences stored locally (not synced to Firebase).
class UserSettingsService {
  UserSettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyDefaultPdfTemplate = 'default_pdf_template';

  String get defaultPdfTemplate {
    final v = _prefs.getString(_keyDefaultPdfTemplate) ?? 'modern';
    return ['modern', 'classic', 'minimal'].contains(v) ? v : 'modern';
  }

  Future<void> setDefaultPdfTemplate(String template) async {
    final safe = ['modern', 'classic', 'minimal'].contains(template) ? template : 'modern';
    await _prefs.setString(_keyDefaultPdfTemplate, safe);
  }
}
