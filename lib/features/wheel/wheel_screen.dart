import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import 'wheel_provider.dart';
import 'decision_wheel.dart';

const _optionLetters = ['A', 'B', 'C', 'D', 'E'];

class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _currentRotation = 0;
  double _angularVelocity = 0;
  bool _isSpinning = false;
  bool _isDragging = false;
  double _lastDragAngle = 0;
  Duration _lastDragTime = Duration.zero;
  Duration _lastTick = Duration.zero;
  double _tickAccumulator = 0;
  double _nextTickAngle = 0;

  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  static const _friction = 1.2;
  static const _minVelocity = 0.08;
  static const _tickInterval = 0.4;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<String> options) {
    while (_controllers.length < options.length) {
      final idx = _controllers.length;
      _controllers.add(TextEditingController(text: options[idx]));
      _focusNodes.add(FocusNode());
    }
    while (_controllers.length > options.length) {
      _controllers.last.dispose();
      _focusNodes.last.dispose();
      _controllers.removeLast();
      _focusNodes.removeLast();
    }
    for (var i = 0; i < options.length; i++) {
      if (_controllers[i].text != options[i] && !_focusNodes[i].hasFocus) {
        _controllers[i].text = options[i];
      }
    }
  }

  static const _wheelSize = 280.0;

  double _getAngleFromCenter(Offset position) {
    final center = Offset(_wheelSize / 2, _wheelSize / 2);
    return atan2(position.dy - center.dy, position.dx - center.dx);
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSpinning) {
      _ticker.stop();
      _isSpinning = false;
    }
    _isDragging = true;
    _lastDragAngle = _getAngleFromCenter(details.localPosition);
    _lastDragTime = details.sourceTimeStamp ?? Duration.zero;
    _angularVelocity = 0;
    ref.read(wheelProvider.notifier).clearSelection();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final currentAngle = _getAngleFromCenter(details.localPosition);
    final delta = currentAngle - _lastDragAngle;

    final now = details.sourceTimeStamp ?? Duration.zero;
    final dt = (now - _lastDragTime).inMicroseconds / 1000000.0;

    if (dt > 0.001 && dt < 0.2) {
      _angularVelocity = delta / dt;
    }

    _lastDragAngle = currentAngle;
    _lastDragTime = now;

    setState(() {
      _currentRotation += delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    if (_angularVelocity.abs() < 0.5) return;

    final wheelState = ref.read(wheelProvider);
    if (wheelState.options.length < 2) return;

    _angularVelocity = _angularVelocity.clamp(-20.0, 20.0);
    _isSpinning = true;

    ref.read(wheelProvider.notifier).startSpin();

    _tickAccumulator = 0;
    _nextTickAngle = _tickInterval;
    _lastTick = Duration.zero;

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    if (dt <= 0 || dt > 0.1) return;

    final decay = exp(-_friction * dt);
    _angularVelocity *= decay;
    _currentRotation += _angularVelocity * dt;

    _tickAccumulator += (_angularVelocity * dt).abs();

    if (_tickAccumulator >= _nextTickAngle &&
        _angularVelocity.abs() > _minVelocity * 2) {
      HapticFeedback.mediumImpact();
      _nextTickAngle += _tickInterval;
    }

    setState(() {});

    if (_angularVelocity.abs() < _minVelocity) {
      _ticker.stop();
      _isSpinning = false;
      _angularVelocity = 0;
      _onSpinComplete();
    }
  }

  void _onSpinComplete() {
    final wheelState = ref.read(wheelProvider);
    final count = wheelState.options.length;
    if (count < 2) return;

    final segmentAngle = 2 * pi / count;
    final normalizedRotation = _currentRotation % (2 * pi);
    final pointerAngle = (2 * pi - normalizedRotation) % (2 * pi);

    int selectedIndex = 0;
    double minDiff = double.infinity;

    for (var i = 0; i < count; i++) {
      final center = i * segmentAngle + segmentAngle / 2;
      final diff = (pointerAngle - center).abs();
      final wrappedDiff = diff > pi ? 2 * pi - diff : diff;
      if (wrappedDiff < minDiff) {
        minDiff = wrappedDiff;
        selectedIndex = i;
      }
    }

    final selectedCenter = selectedIndex * segmentAngle + segmentAngle / 2;
    final finalPointerAngle = (pointerAngle - selectedCenter).abs();
    final wrappedFinal = finalPointerAngle > pi
        ? 2 * pi - finalPointerAngle
        : finalPointerAngle;

    if (wrappedFinal < segmentAngle * 0.08) {
      final nudge = segmentAngle * 0.12;
      final nudgeRotation = pointerAngle < selectedCenter ? nudge : -nudge;
      _currentRotation -= nudgeRotation;
      setState(() {});
    }

    HapticFeedback.heavyImpact();
    ref.read(wheelProvider.notifier).completeSpin(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(wheelProvider);
    final l10n = AppLocalizations.of(context);
    _syncControllers(wheelState.options);

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: bottomPadding + 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildOptionFields(wheelState, l10n),
                    const SizedBox(height: 24),
                    _buildWheel(wheelState),
                    const SizedBox(height: 20),
                    if (wheelState.selectedLabel != null &&
                        wheelState.selectedLabel!.isNotEmpty &&
                        !wheelState.isSpinning)
                      _buildResult(wheelState, l10n)
                    else if (wheelState.selectedIndex != null &&
                        (wheelState.selectedLabel == null ||
                            wheelState.selectedLabel!.isEmpty) &&
                        !wheelState.isSpinning)
                      _buildResultUnnamed(wheelState, l10n),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.decisionWheel,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().slideX(
      begin: -0.1,
      duration: 350.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildOptionFields(WheelState wheelState, AppLocalizations l10n) {
    final canRemove = wheelState.options.length > 2;
    final canAdd = wheelState.options.length < 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var i = 0; i < wheelState.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(
                        wheelColors[i % wheelColors.length],
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(
                          wheelColors[i % wheelColors.length],
                        ).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _optionLetters[i],
                      style: TextStyle(
                        color: Color(wheelColors[i % wheelColors.length]),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (val) {
                        ref.read(wheelProvider.notifier).updateOption(i, val);
                      },
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            '${l10n.optionPlaceholder} ${_optionLetters[i]}',
                        hintStyle: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(
                              wheelColors[i % wheelColors.length],
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (canRemove) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(wheelProvider.notifier).removeOption(i);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (canAdd)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(wheelProvider.notifier).addOption();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l10n.addOption,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWheel(WheelState wheelState) {
    return Column(
      children: [
        Text(
          '▼',
          style: TextStyle(color: AppColors.tertiary, fontSize: 24),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 4),
        GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: DecisionWheelPainter(
                rotation: _currentRotation,
                options: wheelState.options,
              ),
            ),
          ),
        ),
      ],
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildResult(WheelState wheelState, AppLocalizations l10n) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(
                wheelColors[wheelState.selectedIndex! % wheelColors.length],
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(
                  wheelColors[wheelState.selectedIndex! % wheelColors.length],
                ).withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.resultLabel,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wheelState.selectedLabel!,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _optionLetters[wheelState.selectedIndex!],
                style: TextStyle(
                  color: Color(
                    wheelColors[wheelState.selectedIndex! % wheelColors.length],
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildResultUnnamed(WheelState wheelState, AppLocalizations l10n) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(
                wheelColors[wheelState.selectedIndex! % wheelColors.length],
              ),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.resultLabel,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _optionLetters[wheelState.selectedIndex!],
                style: TextStyle(
                  color: Color(
                    wheelColors[wheelState.selectedIndex! % wheelColors.length],
                  ),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }
}
