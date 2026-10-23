import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _clave = 'cubanum_tema_oscuro';

  bool _oscuro = false;
  bool get oscuro => _oscuro;
  ThemeMode get modo => _oscuro ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _oscuro = prefs.getBool(_clave) ?? false;
    notifyListeners();
  }

  Future<void> alternar(bool valor) async {
    _oscuro = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, valor);
  }
}
