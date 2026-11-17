import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Odak arkadaşı karakterinin modu.
enum BuddyMood { idle, working, sleeping, cheering }

/// Odak buddiesının durumu: zamanlayıcı ile birlikte karakterin
/// modunu da tutar.
///
/// Zaman [endTime] üzerinden geri sayılır; [mood] karakterin
/// ekrandaki davranışını belirler.
class BuddyState {
  final Duration duration;
  final bool isRunning;
  final bool isPaused;
  final DateTime? endTime;
  final BuddyMood mood;

  const BuddyState({
    this.duration = const Duration(minutes: 25),
    this.isRunning = false,
    this.isPaused = false,
    this.endTime,
    this.mood = BuddyMood.idle,
  });

  BuddyState copyWith({
    Duration? duration,
    bool? isRunning,
    bool? isPaused,
    DateTime? Function()? endTime,
    BuddyMood? mood,
  }) {
    return BuddyState(
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      endTime: endTime != null ? endTime() : this.endTime,
      mood: mood ?? this.mood,
    );
  }

  Duration get remaining {
    if (endTime == null) return duration;
    final diff = endTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isComplete => isRunning && remaining == Duration.zero;
}

class BuddyNotifier extends StateNotifier<BuddyState> {
  Timer? _timer;
  Timer? _moodTimer;

  BuddyNotifier() : super(const BuddyState()) {
    _startMoodCycle();
  }

  void _startMoodCycle() {
    _moodTimer?.cancel();
    _moodTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (state.isRunning && !state.isPaused) {
        if (state.mood == BuddyMood.working) {
          state = state.copyWith(mood: BuddyMood.idle);
        } else if (state.mood == BuddyMood.idle) {
          state = state.copyWith(mood: BuddyMood.working);
        }
      }
    });
  }

  void startTimer() {
    final end = DateTime.now().add(state.duration);
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      mood: BuddyMood.working,
      endTime: () => end,
    );
    _startTick();
    _startMoodCycle();
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isComplete) {
        _timer?.cancel();
        _moodTimer?.cancel();
        state = state.copyWith(
          isRunning: false,
          isPaused: false,
          mood: BuddyMood.cheering,
          endTime: () => null,
        );
        return;
      }
      if (!state.isPaused) {
        state = state.copyWith();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _moodTimer?.cancel();
    state = state.copyWith(isPaused: true, mood: BuddyMood.sleeping);
  }

  void resumeTimer() {
    if (!state.isPaused || state.endTime == null) return;
    final elapsed = state.duration - state.remaining;
    final newEnd = DateTime.now().add(state.duration - elapsed);
    state = state.copyWith(
      isPaused: false,
      endTime: () => newEnd,
      mood: BuddyMood.working,
    );
    _startTick();
    _startMoodCycle();
  }

  void stopTimer() {
    _timer?.cancel();
    _moodTimer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      mood: BuddyMood.idle,
      endTime: () => null,
    );
  }

  void setDuration(Duration d) {
    if (state.isRunning) return;
    state = state.copyWith(duration: d);
  }

  void updateMood(BuddyMood m) {
    state = state.copyWith(mood: m);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _moodTimer?.cancel();
    super.dispose();
  }
}

final buddyProvider = StateNotifierProvider<BuddyNotifier, BuddyState>((ref) {
  return BuddyNotifier();
});
