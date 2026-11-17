import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_icon_widget.dart';
import '../energy/energy_provider.dart';
import '../tasks/tasks_screen.dart';
import '../aura_timer/aura_timer_screen.dart';
import '../focus_buddy/focus_buddy_screen.dart';
import '../wait_mode/wait_mode_screen.dart';
import '../wheel/wheel_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentEnergy = ref.watch(energyProvider);

    final screens = [
      const TasksScreen(),
      _ToolsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AppIconWidget(size: 28),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (currentEnergy != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: EnergyUtils.getColor(
                    currentEnergy,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: EnergyUtils.getColor(
                      currentEnergy,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  EnergyUtils.getLabel(currentEnergy, l10n),
                  style: TextStyle(
                    color: EnergyUtils.getColor(currentEnergy),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.eco),
            label: l10n.tasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement),
            label: l10n.focus,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class _ToolsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tools = [
      _ToolCard(
        icon: Icons.palette,
        title: l10n.auraTimer,
        subtitle: l10n.auraDescription,
        color: AppColors.tertiary,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AuraTimerScreen())),
      ),
      _ToolCard(
        icon: Icons.smart_toy,
        title: l10n.focusBuddy,
        subtitle: l10n.buddyIdle,
        color: AppColors.secondary,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FocusBuddyScreen())),
      ),
      _ToolCard(
        icon: Icons.hourglass_bottom,
        title: l10n.waitMode,
        subtitle: l10n.waitModeDescription,
        color: AppColors.primary,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WaitModeScreen())),
      ),
      _ToolCard(
        icon: Icons.casino,
        title: l10n.decisionWheel,
        subtitle: l10n.cantDecide,
        color: const Color(0xFFFFA726),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WheelScreen())),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: tools[index],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
