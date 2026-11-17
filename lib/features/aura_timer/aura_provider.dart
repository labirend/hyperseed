import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aura zamanlayıcısının durumu.
///
/// Zaman [endTime] üzerinden geri sayılır; böylece uygulama arka
/// plana alınsa bile süre doğru akar. [elapsed] 0–1 arası ilerleme
/// oranıdır ve görsel gradyanı besler.
class AuraState {
  final Duration duration;
  final bool isRunning;
  final bool isPaused;
  final DateTime? endTime;

  const AuraState({
    this.duration = const Duration(minutes: 25),
    this.isRunning = false,
    this.isPaused = false,
    this.endTime,
  });

  Duration get remaining {
    if (endTime == null) return duration;
    final diff = endTime!.difference(DateTime.now());
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  double get elapsed {
    if (duration.inMilliseconds == 0) return 0;
    final total = duration.inMilliseconds - remaining.inMilliseconds;
    return (total / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  bool get isComplete => isRunning && remaining == Duration.zero;

  AuraState copyWith({
    Duration? duration,
    bool? isRunning,
    bool? isPaused,
    DateTime? endTime,
    bool clearEndTime = false,
  }) {
    return AuraState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
}

class AuraNotifier extends StateNotifier<AuraState> {
  Timer? _ticker;

  AuraNotifier() : super(const AuraState());

  void startTimer() {
    _ticker?.cancel();
    final endTime = DateTime.now().add(state.duration);
    state = state.copyWith(isRunning: true, isPaused: false, endTime: endTime);
    _startTicker();
  }

  void pauseTimer() {
    _ticker?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    final remaining = state.remaining;
    if (remaining <= Duration.zero) return;
    final endTime = DateTime.now().add(remaining);
    state = state.copyWith(isPaused: false, endTime: endTime);
    _startTicker();
  }

  void stopTimer() {
    _ticker?.cancel();
    state = const AuraState();
  }

  void setDuration(Duration d) {
    if (state.isRunning) return;
    state = state.copyWith(duration: d);
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isComplete) {
        _ticker?.cancel();
        state = state.copyWith(isRunning: false);
        return;
      }
      state = state.copyWith(endTime: state.endTime);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final auraProvider = StateNotifierProvider<AuraNotifier, AuraState>((ref) {
  return AuraNotifier();
});
