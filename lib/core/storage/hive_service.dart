import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  Box<T> openBox<T>(String name) {
    return Hive.box<T>(name);
  }

  Future<Box<T>> openBoxAsync<T>(String name) async {
    await _ensureInitialized();
    return await Hive.openBox<T>(name);
  }

  bool boxExists(String name) {
    return Hive.isBoxOpen(name);
  }
}