import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/transitions.dart';
import '../../services/hive_service.dart';
import '../../shared/widgets/neon_button.dart';
import '../energy/energy_screen.dart';

class _CategoryData {
  final String id;
  final String label;
  final String englishLabel;
  final IconData icon;
  final List<_SubcategoryData> subcategories;

  _CategoryData({
    required this.id,
    required this.label,
    required this.englishLabel,
    required this.icon,
    required this.subcategories,
  });
}

class _SubcategoryData {
  final String id;
  final String label;
  final String englishLabel;
  final List<_ItemData> items;

  _SubcategoryData({
    required this.id,
    required this.label,
    required this.englishLabel,
    required this.items,
  });
}

class _ItemData {
  final String id;
  final String text;
  final String englishText;

  _ItemData({required this.id, required this.text, required this.englishText});
}

const _iconMap = <String, IconData>{
  'music': Icons.music_note,
  'tech': Icons.code,
  'art': Icons.palette,
  'fitness': Icons.fitness_center,
  'daily_life': Icons.home,
};

class PreferencesScreen extends StatefulWidget {
  final bool isOnboarding;

  const PreferencesScreen({super.key, this.isOnboarding = false});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  int _currentStep = 0;
  List<_CategoryData> _categories = [];
  final Set<String> _selectedMainIds = {};
  final Map<String, Set<String>> _selectedSubIds = {};
  final Set<String> _selectedItemIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jsonString = await rootBundle.loadString('assets/activities_v2.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final categories = jsonData['categories'] as List<dynamic>;

    final List<_CategoryData> result = [];
    for (final cat in categories) {
      final subcategories = cat['subcategories'] as List<dynamic>;
      final List<_SubcategoryData> subs = [];
      for (final sub in subcategories) {
        final items = sub['items'] as List<dynamic>;
        final List<_ItemData> itemList = [];
        for (final item in items) {
          itemList.add(
            _ItemData(
              id: item['id'] as String,
              text: item['text'] as String,
              englishText: item['englishText'] as String,
            ),
          );
        }
        subs.add(
          _SubcategoryData(
            id: sub['id'] as String,
            label: sub['label'] as String,
            englishLabel: sub['englishLabel'] as String,
            items: itemList,
          ),
        );
      }
      result.add(
        _CategoryData(
          id: cat['id'] as String,
          label: cat['label'] as String,
          englishLabel: cat['englishLabel'] as String,
          icon: _iconMap[cat['id'] as String] ?? Icons.category,
          subcategories: subs,
        ),
      );
    }

    final saved = HiveService.getUserPreferences().toSet();
    setState(() {
      _categories = result;
      _selectedItemIds.addAll(saved);
      _loading = false;
    });
  }

  void _toggleMain(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedMainIds.contains(id)) {
        _selectedMainIds.remove(id);
        _selectedSubIds.remove(id);
      } else {
        if (_selectedMainIds.length >= 3) return;
        _selectedMainIds.add(id);
      }
    });
  }

  void _toggleSub(String mainId, String subId) {
    HapticFeedback.lightImpact();
    setState(() {
      final subs = _selectedSubIds[mainId] ?? <String>{};
      if (subs.contains(subId)) {
        subs.remove(subId);
      } else {
        if (subs.length >= 5) return;
        subs.add(subId);
      }
      _selectedSubIds[mainId] = subs;
    });
  }

  void _toggleItem(String itemId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _toggleSelectAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      final allIds = _getFilteredItemIds();
      final allSelected = allIds.every((id) => _selectedItemIds.contains(id));
      if (allSelected) {
        _selectedItemIds.removeAll(allIds);
      } else {
        _selectedItemIds.addAll(allIds);
      }
    });
  }

  Set<String> _getFilteredItemIds() {
    final ids = <String>{};
    for (final cat in _categories) {
      if (!_selectedMainIds.contains(cat.id)) continue;
      for (final sub in cat.subcategories) {
        if (!(_selectedSubIds[cat.id]?.contains(sub.id) ?? false)) continue;
        for (final item in sub.items) {
          ids.add(item.id);
        }
      }
    }
    return ids;
  }

  void _goNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else if (!widget.isOnboarding) {
      Navigator.of(context).pop();
    }
  }

  void _save() {
    HiveService.setUserPreferences(_selectedItemIds.toList());
    if (widget.isOnboarding) {
      Navigator.of(
        context,
      ).pushReplacement(NeonPageRoute(page: const EnergyScreen()));
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedMainIds.isNotEmpty;
      case 1:
        return _selectedSubIds.values.any((s) => s.isNotEmpty);
      case 2:
        return _selectedItemIds.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              title: Text(
                l10n.interests,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.onBackground,
              elevation: 0,
            ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: Column(
                children: [
                  if (widget.isOnboarding) ...[
                    const SizedBox(height: 32),
                    Text(
                          l10n.interests,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 8),
                  ],
                  _buildStepIndicator(l10n),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _getStepDescription(l10n, isTr),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildStepContent(l10n, isTr)),
                  _buildBottomButtons(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildStepIndicator(AppLocalizations l10n) {
    final labels = [
      l10n.stepMainCategories,
      l10n.stepSubCategories,
      l10n.stepInterests,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone || isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isDone
                            ? AppColors.primary
                            : AppColors.surface,
                        border: Border.all(
                          color: isActive || isDone
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: AppColors.background,
                                size: 14,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.background
                                      : AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepDescription(AppLocalizations l10n, bool isTr) {
    switch (_currentStep) {
      case 0:
        return l10n.interestsDesc;
      case 1:
        return l10n.interestsSubDesc;
      case 2:
        return l10n.interestsFinal;
      default:
        return '';
    }
  }

  Widget _buildStepContent(AppLocalizations l10n, bool isTr) {
    switch (_currentStep) {
      case 0:
        return _buildMainCategories(l10n, isTr);
      case 1:
        return _buildSubCategories(l10n, isTr);
      case 2:
        return _buildItemList(l10n, isTr);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMainCategories(AppLocalizations l10n, bool isTr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_categories.length, (index) {
          final cat = _categories[index];
          final isSelected = _selectedMainIds.contains(cat.id);
          final label = isTr ? cat.label : cat.englishLabel;

          return GestureDetector(
            onTap: () => _toggleMain(cat.id),
            child:
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 50) / 2,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.15),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          cat.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.onBackground
                              : AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 6),
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 60),
                  duration: 300.ms,
                ),
          );
        }),
      ),
    );
  }

  Widget _buildSubCategories(AppLocalizations l10n, bool isTr) {
    final selectedCats = _categories
        .where((c) => _selectedMainIds.contains(c.id))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: selectedCats.length,
      itemBuilder: (context, catIndex) {
        final cat = selectedCats[catIndex];
        final catLabel = isTr ? cat.label : cat.englishLabel;
        final selectedSubs = _selectedSubIds[cat.id] ?? <String>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (catIndex > 0) const SizedBox(height: 20),
            Row(
              children: [
                Icon(cat.icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  catLabel,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cat.subcategories.map((sub) {
                final isSelected = selectedSubs.contains(sub.id);
                final subLabel = isTr ? sub.label : sub.englishLabel;

                return GestureDetector(
                  onTap: () => _toggleSub(cat.id, sub.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant.withValues(
                                alpha: 0.15,
                              ),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subLabel,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.onBackground
                                : AppColors.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemList(AppLocalizations l10n, bool isTr) {
    final allFiltered = _getFilteredItemIds();
    final allSelected =
        allFiltered.isNotEmpty &&
        allFiltered.every((id) => _selectedItemIds.contains(id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GestureDetector(
            onTap: _toggleSelectAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: allSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: allSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allSelected ? Icons.deselect : Icons.select_all,
                    color: allSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allSelected ? l10n.deselectAll : l10n.selectAll,
                    style: TextStyle(
                      color: allSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildFilteredItems(l10n, isTr),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFilteredItems(AppLocalizations l10n, bool isTr) {
    final List<Widget> widgets = [];
    for (final cat in _categories) {
      if (!_selectedMainIds.contains(cat.id)) continue;
      for (final sub in cat.subcategories) {
        if (!(_selectedSubIds[cat.id]?.contains(sub.id) ?? false)) continue;
        for (final item in sub.items) {
          final isSelected = _selectedItemIds.contains(item.id);
          final label = isTr ? item.text : item.englishText;
          widgets.add(
            GestureDetector(
              onTap: () => _toggleItem(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.15),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.onBackground
                              : AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    return widgets;
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    final bool canProceed = _canProceed();
    final bool isLastStep = _currentStep == 2;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0 || !widget.isOnboarding)
            Expanded(
              child: NeonButton(
                text: widget.isOnboarding && _currentStep == 0
                    ? ''
                    : l10n.cancel,
                color: AppColors.onSurfaceVariant,
                onPressed: _goBack,
                width: double.infinity,
                enabled: true,
              ),
            ),
          if (_currentStep > 0 || !widget.isOnboarding)
            const SizedBox(width: 12),
          Expanded(
            child: NeonButton(
              text: isLastStep
                  ? widget.isOnboarding
                        ? l10n.getStarted
                        : l10n.save
                  : l10n.getStarted,
              color: AppColors.primary,
              onPressed: canProceed ? _goNext : () {},
              width: double.infinity,
              enabled: canProceed,
            ),
          ),
        ],
      ),
    );
  }
}
