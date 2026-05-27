import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
	HiveService._();

	static final HiveService instance = HiveService._();

	Future<void> initialize() async {
		await Hive.initFlutter();
	}

	Box<T> openBox<T>(String name) {
		return Hive.box<T>(name);
	}

	Future<Box<T>> openBoxAsync<T>(String name) async {
		return await Hive.openBox<T>(name);
	}

	bool boxExists(String name) {
		return Hive.isBoxOpen(name);
	}
}