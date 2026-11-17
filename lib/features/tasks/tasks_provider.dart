import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../models/energy_level.dart';
import '../../services/task_service.dart';
import '../energy/energy_provider.dart';

/// Aktif seviyeye göre filtrelenmiş görev listesini yönetir.
///
/// [energy] verilirse yalnızca o seviyedeki tamamlanmamış görevler,
/// null ise tüm görevler gösterilir. Her yazma işleminden sonra liste
/// Hive'dan yeniden yüklenir.
class TasksNotifier extends StateNotifier<List<Task>> {
  final EnergyLevel? energy;

  TasksNotifier(this.energy) : super([]) {
    loadTasks();
  }

  void loadTasks() {
    if (energy != null) {
      state = TaskService.getTasksForEnergy(energy!);
    } else {
      state = TaskService.getAllTasks();
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      await TaskService.addTask(task);
      loadTasks();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateTask(Task task) async {
    await TaskService.updateTask(task);
    loadTasks();
  }

  Future<void> completeTask(String taskId) async {
    await TaskService.completeTask(taskId);
    loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await TaskService.deleteTask(taskId);
    loadTasks();
  }

  Future<bool> addRandomTask({String locale = 'tr'}) async {
    if (energy == null) return false;
    try {
      final task = await TaskService.getRandomTaskFromPool(
        energy!,
        locale: locale,
      );
      if (task != null) {
        return await addTask(task);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final energy = ref.watch(energyProvider);
  return TasksNotifier(energy);
});

final completedTodayProvider = Provider<List<Task>>((ref) {
  return TaskService.getCompletedTasksForToday();
});

final incompleteTasksProvider = Provider<List<Task>>((ref) {
  return TaskService.getIncompleteTasks();
});

final poolExhaustedProvider = FutureProvider<bool>((ref) async {
  ref.watch(tasksProvider);
  final energy = ref.watch(energyProvider);
  if (energy == null) return false;
  return TaskService.isPoolExhausted(energy);
});
