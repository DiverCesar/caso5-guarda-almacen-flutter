import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/entrega_card.dart';
import '../widgets/formulario_entrega_sheet.dart';

class EntregasView extends StatefulWidget {
  const EntregasView({super.key});

  @override
  State<EntregasView> createState() => _EntregasViewState();
}

class _EntregasViewState extends State<EntregasView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas y Custodia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.outbox_rounded, size: 22),
            tooltip: 'Registrar nueva entrega',
            onPressed: () {
              HapticFeedback.lightImpact();
              FormularioEntregaSheet.show(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primario,
          unselectedLabelColor: AppTheme.textoSecundario,
          indicatorColor: AppTheme.acento,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Activas en Guarda'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.acento.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${vm.entregasActivas.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.acento),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Devueltas'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${vm.entregasDevueltas.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.acento,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.outbox_rounded, size: 20),
        label: const Text('Nueva Entrega', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onPressed: () {
          HapticFeedback.lightImpact();
          FormularioEntregaSheet.show(context);
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Entregas Activas
          RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await vm.cargarTodo();
            },
            child: Column(
              children: [
                // Banner con microinteracción
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: const Color(0xFFF1F5F9),
                  child: const Row(
                    children: [
                      Icon(Icons.swipe_right_rounded, size: 14, color: AppTheme.textoSecundario),
                      SizedBox(width: 6),
                      Text(
                        'Desliza una entrega a la derecha para registrar su devolución rápida.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: vm.entregasActivas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.fondo,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.borde),
                                ),
                                child: const Icon(Icons.all_inbox_rounded, size: 36, color: AppTheme.textoSecundario),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay entregas activas en este momento',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primario),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Todos los bienes se encuentran almacenados en custodia.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: vm.entregasActivas.length,
                          itemBuilder: (context, index) {
                            final entrega = vm.entregasActivas[index];
                            return EntregaCard(entrega: entrega);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Pestaña 2: Entregas Devueltas
          RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await vm.cargarTodo();
            },
            child: vm.entregasDevueltas.isEmpty
                ? const Center(
                    child: Text(
                      'No hay historial de devoluciones registradas.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textoSecundario),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: vm.entregasDevueltas.length,
                    itemBuilder: (context, index) {
                      final entrega = vm.entregasDevueltas[index];
                      return EntregaCard(entrega: entrega);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
