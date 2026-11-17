import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bekleme modunun durumu: randevu saati ve aralığı dolduran
/// kısa görevlerin kimlikleri.
///
/// [getTimeRemaining] randevuya kalan süreyi döndürür; süre
/// dolduysa null döner.
class WaitState {
  final DateTime? appointmentTime;
  final bool isActive;
  final List<String> fillingTaskIds;

  const WaitState({
    this.appointmentTime,
    this.isActive = false,
    this.fillingTaskIds = const [],
  });

  WaitState copyWith({
    DateTime? appointmentTime,
    bool? isActive,
    List<String>? fillingTaskIds,
  }) {
    return WaitState(
      appointmentTime: appointmentTime ?? this.appointmentTime,
      isActive: isActive ?? this.isActive,
      fillingTaskIds: fillingTaskIds ?? this.fillingTaskIds,
    );
  }

  Duration? getTimeRemaining() {
    if (appointmentTime == null) return null;
    final remaining = appointmentTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}

class WaitNotifier extends StateNotifier<WaitState> {
  WaitNotifier() : super(const WaitState());

  void setAppointmentTime(DateTime time) {
    state = state.copyWith(appointmentTime: time);
  }

  void startWaitMode() {
    state = state.copyWith(isActive: true);
  }

  void stopWaitMode() {
    state = state.copyWith(isActive: false);
  }

  void addFillingTask(String taskId) {
    if (!state.fillingTaskIds.contains(taskId)) {
      state = state.copyWith(fillingTaskIds: [...state.fillingTaskIds, taskId]);
    }
  }

  void removeFillingTask(String taskId) {
    state = state.copyWith(
      fillingTaskIds: state.fillingTaskIds.where((id) => id != taskId).toList(),
    );
  }

  Duration? getTimeRemaining() {
    return state.getTimeRemaining();
  }
}

final waitProvider = StateNotifierProvider<WaitNotifier, WaitState>((ref) {
  return WaitNotifier();
});
