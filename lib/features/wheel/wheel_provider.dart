import 'package:flutter_riverpod/flutter_riverpod.dart';

const wheelColors = [
  0xFF39FF14,
  0xFF00FFFF,
  0xFFBC13FE,
  0xFFFF6B9D,
  0xFFFFB300,
];

/// Karar çarkının durumu: döndürülecek seçenekler ve sonuç.
///
/// Çark dönerken [isSpinning] true olur; durduğunda [selectedIndex]
/// ve [selectedLabel] kazananı tutar.
class WheelState {
  final List<String> options;
  final bool isSpinning;
  final int? selectedIndex;
  final String? selectedLabel;

  const WheelState({
    required this.options,
    this.isSpinning = false,
    this.selectedIndex,
    this.selectedLabel,
  });

  WheelState copyWith({
    List<String>? options,
    bool? isSpinning,
    int? selectedIndex,
    String? selectedLabel,
    bool clearSelected = false,
  }) {
    return WheelState(
      options: options ?? this.options,
      isSpinning: isSpinning ?? this.isSpinning,
      selectedIndex: clearSelected
          ? null
          : (selectedIndex ?? this.selectedIndex),
      selectedLabel: clearSelected
          ? null
          : (selectedLabel ?? this.selectedLabel),
    );
  }
}

class WheelNotifier extends StateNotifier<WheelState> {
  WheelNotifier() : super(WheelState(options: const ['', '']));

  void addOption() {
    if (state.options.length >= 5) return;
    state = state.copyWith(options: [...state.options, '']);
  }

  void removeOption(int index) {
    if (state.options.length <= 2) return;
    final updated = List<String>.from(state.options);
    updated.removeAt(index);
    state = state.copyWith(options: updated);
  }

  void updateOption(int index, String text) {
    final updated = List<String>.from(state.options);
    updated[index] = text;
    state = state.copyWith(options: updated);
  }

  void startSpin() {
    state = state.copyWith(isSpinning: true, clearSelected: true);
  }

  void completeSpin(int index) {
    final label = index < state.options.length ? state.options[index] : '';
    state = state.copyWith(
      isSpinning: false,
      selectedIndex: index,
      selectedLabel: label,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }
}

final wheelProvider = StateNotifierProvider<WheelNotifier, WheelState>((ref) {
  return WheelNotifier();
});
