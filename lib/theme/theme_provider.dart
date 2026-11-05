import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _clave = 'cubanum_tema_id';

  AppThemeId _id = AppThemeId.claro;
  AppThemeId get id => _id;

  ThemeData get tema => AppTheme.porId(_id);
  String get nombre => AppTheme.nombre(_id);

  ThemeProvider() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(_clave);
    if (guardado != null) {
      try {
        _id = AppThemeId.values.firstWhere((e) => e.name == guardado);
      } catch (_) {
        _id = AppThemeId.claro;
      }
    }
    notifyListeners();
  }

  Future<void> cambiar(AppThemeId nuevo) async {
    if (nuevo == _id) return;
    _id = nuevo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, nuevo.name);
  }
}
