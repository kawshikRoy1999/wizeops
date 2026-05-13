import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage _storage;
  static const _key = 'theme_mode';

  ThemeCubit(this._storage) : super(ThemeMode.light);

  Future<void> loadSaved() async {
    final saved = await _storage.read(key: _key);
    emit(saved == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggle() async {
    final next =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(key: _key, value: next == ThemeMode.dark ? 'dark' : 'light');
    emit(next);
  }

  bool get isDark => state == ThemeMode.dark;
}
