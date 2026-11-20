import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'bienes_view.dart';
import 'dashboard_view.dart';
import 'entregas_view.dart';
import 'responsables_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _indiceActual = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indiceActual);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _cambiarPestana(int index) {
    if (_indiceActual == index) return;
    HapticFeedback.selectionClick();
    setState(() => _indiceActual = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          HapticFeedback.selectionClick();
          setState(() => _indiceActual = index);
        },
        children: [
          DashboardView(onNavigateToTab: _cambiarPestana),
          const BienesView(),
          const EntregasView(),
          const ResponsablesView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.superficie,
          border: Border(top: BorderSide(color: AppTheme.borde, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _indiceActual,
          onDestinationSelected: _cambiarPestana,
          backgroundColor: AppTheme.superficie,
          elevation: 0,
          indicatorColor: AppTheme.primario.withValues(alpha: 0.08),
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 20, color: AppTheme.textoSecundario),
              selectedIcon: Icon(Icons.dashboard_rounded, size: 20, color: AppTheme.primario),
              label: 'Resumen',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.textoSecundario),
              selectedIcon: Icon(Icons.inventory_2_rounded, size: 20, color: AppTheme.primario),
              label: 'Bienes',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, size: 20, color: AppTheme.textoSecundario),
              selectedIcon: Icon(Icons.assignment_rounded, size: 20, color: AppTheme.primario),
              label: 'Entregas',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, size: 20, color: AppTheme.textoSecundario),
              selectedIcon: Icon(Icons.people_rounded, size: 20, color: AppTheme.primario),
              label: 'Responsables',
            ),
          ],
        ),
      ),
    );
  }
}
