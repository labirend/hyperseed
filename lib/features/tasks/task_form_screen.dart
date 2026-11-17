import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';
import '../../models/energy_level.dart';
import '../../shared/widgets/neon_button.dart';
import 'tasks_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  EnergyLevel _selectedEnergy = EnergyLevel.low;
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _durationController.text = widget.task!.durationMin.toString();
      _selectedEnergy = widget.task!.energyLevel;
    } else {
      _durationController.text = '15';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTask : l10n.addTask),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.taskTitle,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(hintText: l10n.taskTitle),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.taskTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.taskDuration,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                style: const TextStyle(color: AppColors.onSurface),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.taskDuration,
                  suffixText: l10n.minutes,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '';
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) return '';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.taskEnergy,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildEnergyChips(l10n),
              const SizedBox(height: 40),
              NeonButton(
                text: l10n.save,
                width: double.infinity,
                color: AppColors.primary,
                onPressed: _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyChips(AppLocalizations l10n) {
    return Row(
      children: EnergyLevel.values.map((level) {
        final isSelected = _selectedEnergy == level;
        final color = EnergyUtils.getColor(level);
        final label = EnergyUtils.getLabel(level, l10n);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedEnergy = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : color.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final duration = int.tryParse(_durationController.text) ?? 15;

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        energyLevel: _selectedEnergy,
        durationMin: duration,
      );
      ref.read(tasksProvider.notifier).updateTask(updated);
    } else {
      final task = Task(
        id: const Uuid().v4(),
        title: title,
        energyLevel: _selectedEnergy,
        durationMin: duration,
      );
      ref.read(tasksProvider.notifier).addTask(task);
    }

    Navigator.of(context).pop();
  }
}
