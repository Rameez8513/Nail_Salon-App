import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../features/inventory/screens/inventory_screen.dart';
import '../../../features/customers/screens/clients_screen.dart';
import '../../../features/appointments/screens/schedules_screen.dart';
import '../../../features/services/screens/services_screen.dart';
import '../../../features/employee/screens/employees_screen.dart';
import '../../../features/settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = const [
    InventoryScreen(),
    ClientsScreen(),
    SchedulesScreen(),
    ServicesScreen(),
    EmployeesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();

    final navItems = [
      NavItem(
        icon: Icons.content_cut_outlined,
        activeIcon: Icons.content_cut,
        label: AppStrings.t('inventory'),
      ),
      NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: AppStrings.t('clients'),
      ),
      NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: AppStrings.t('schedules'),
      ),
      NavItem(
        icon: Icons.back_hand_outlined,
        activeIcon: Icons.back_hand,
        label: AppStrings.t('services'),
      ),
      NavItem(
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: AppStrings.t('employees'),
      ),
      NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: AppStrings.t('settings'),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }
}
