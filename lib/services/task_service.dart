import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../models/task.dart';
import '../models/energy_level.dart';
import 'hive_service.dart';

/// Görev CRUD işlemleri ve aktivite havuzu önerileri.
///
/// Tüm sorgular Hive üzerinden çalışır; [getRandomTaskFromPool] ise
/// yerel `assets/activities_v2.json` dosyasından, kullanıcının enerji
/// seviyesine ve ilgi kategorilerine uygun rastgele bir görev üretir.
class TaskService {
  /// Kutudaki tüm görevleri döndürür (tamamlananlar dahil).
  static List<Task> getAllTasks() {
    return HiveService.taskBox.values.toList();
  }

  /// Enerji seviyesine uygun ve henüz tamamlanmamış görevleri döndürür.
  static List<Task> getTasksForEnergy(EnergyLevel energy) {
    return HiveService.taskBox.values
        .where((t) => t.energyLevel == energy && !t.isCompleted)
        .toList();
  }

  static List<Task> getCompletedTasksForToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return HiveService.taskBox.values
        .where(
          (t) =>
              t.isCompleted &&
              t.completedAt != null &&
              t.completedAt!.isAfter(startOfDay),
        )
        .toList();
  }

  static List<Task> getIncompleteTasks() {
    return HiveService.taskBox.values.where((t) => !t.isCompleted).toList();
  }

  /// Yeni görev ekler; günlük limit açıksa limit aşılamaz.
  ///
  /// Limit aşılmaya çalışılırsa `daily_limit_reached` mesajıyla
  /// exception fırlatır.
  static Future<void> addTask(Task task) async {
    final enabled = HiveService.getDailyLimitEnabled();
    if (enabled) {
      final todayTasks = getIncompleteTasks();
      if (todayTasks.length >= AppConstants.dailyTaskLimit) {
        throw Exception('daily_limit_reached');
      }
    }
    await HiveService.taskBox.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await HiveService.taskBox.put(task.id, task);
  }

  static Future<void> completeTask(String taskId) async {
    final task = HiveService.taskBox.get(taskId);
    if (task != null) {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      await task.save();
    }
  }

  static Future<void> deleteTask(String taskId) async {
    await HiveService.taskBox.delete(taskId);
  }

  static Future<Map<String, dynamic>> _loadActivityPool() async {
    final jsonString = await rootBundle.loadString('assets/activities_v2.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> _extractAllItems(
    Map<String, dynamic> jsonData,
  ) {
    final categories = jsonData['categories'] as List<dynamic>;
    final List<Map<String, dynamic>> allItems = [];
    for (final category in categories) {
      final catId = category['id'] as String;
      final subcategories = category['subcategories'] as List<dynamic>;
      for (final sub in subcategories) {
        final items = sub['items'] as List<dynamic>;
        for (final item in items) {
          allItems.add({
            ...Map<String, dynamic>.from(item),
            'categoryId': catId,
          });
        }
      }
    }
    return allItems;
  }

  /// Havuzdan enerjiye uygun rastgele bir görev önerisi üretir.
  ///
  /// Öneriler; kullanıcının ilgi kategorilerine, enerji seviyesine ve
  /// daha önce atanmış ama tamamlanmamış öğelere göre filtrelenir.
  /// [locale] `en` ise İngilizce başlık döner. Havuz tükendiyse null.
  static Future<Task?> getRandomTaskFromPool(
    EnergyLevel energy, {
    String locale = 'tr',
  }) async {
    final jsonData = await _loadActivityPool();
    final allItems = _extractAllItems(jsonData);
    final preferences = HiveService.getUserPreferences();

    List<Map<String, dynamic>> candidates;

    if (preferences.isNotEmpty) {
      candidates = allItems
          .where((item) => preferences.contains(item['id']))
          .toList();
      if (candidates.isEmpty) candidates = allItems;
    } else {
      candidates = allItems;
    }

    var filtered = candidates.where((item) {
      final difficulty = item['difficulty'] as int;
      if (energy == EnergyLevel.low) return difficulty <= 2;
      if (energy == EnergyLevel.hyperfocus) return difficulty >= 3;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      filtered = candidates;
    }
    if (filtered.isEmpty) return null;

    final existingPoolIds = HiveService.taskBox.values
        .where((t) => t.poolItemId != null && !t.isCompleted)
        .map((t) => t.poolItemId!)
        .toSet();

    final available = filtered
        .where((item) => !existingPoolIds.contains(item['id']))
        .toList();

    if (available.isEmpty) return null;

    final random = Random();
    final picked = available[random.nextInt(available.length)];
    final energyLevel = energy == EnergyLevel.chaos
        ? EnergyLevel.values[random.nextInt(3)]
        : energy;

    final title = locale == 'en'
        ? (picked['englishText'] as String? ?? picked['text'] as String)
        : picked['text'] as String;

    return Task(
      id: 'pool_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      energyLevel: energyLevel,
      durationMin: 15,
      tags: (picked['tags'] as List<dynamic>).map((e) => e as String).toList(),
      poolItemId: picked['id'] as String,
    );
  }

  static Future<bool> isPoolExhausted(EnergyLevel energy) async {
    final jsonData = await _loadActivityPool();
    final allItems = _extractAllItems(jsonData);
    final preferences = HiveService.getUserPreferences();

    List<Map<String, dynamic>> candidates;
    if (preferences.isNotEmpty) {
      candidates = allItems
          .where((item) => preferences.contains(item['id']))
          .toList();
      if (candidates.isEmpty) candidates = allItems;
    } else {
      candidates = allItems;
    }

    var filtered = candidates.where((item) {
      final difficulty = item['difficulty'] as int;
      if (energy == EnergyLevel.low) return difficulty <= 2;
      if (energy == EnergyLevel.hyperfocus) return difficulty >= 3;
      return true;
    }).toList();

    if (filtered.isEmpty) filtered = candidates;

    final existingPoolIds = HiveService.taskBox.values
        .where((t) => t.poolItemId != null && !t.isCompleted)
        .map((t) => t.poolItemId!)
        .toSet();

    return filtered.every((item) => existingPoolIds.contains(item['id']));
  }
}
