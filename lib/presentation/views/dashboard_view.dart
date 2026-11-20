import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/formulario_entrega_sheet.dart';
import '../widgets/formulario_responsable_sheet.dart';
import '../widgets/kpi_card.dart';

class DashboardView extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardView({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.warehouse_rounded, size: 22, color: AppTheme.primario),
            SizedBox(width: 8),
            Text('Guarda de Almacén'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 20),
            tooltip: 'Sincronizar datos',
            onPressed: () {
              HapticFeedback.lightImpact();
              vm.cargarTodo();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await vm.cargarTodo();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Saludo y subtítulo institucional
            const Text(
              'Panel de Control Institucional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primario,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Caso 5: Gestión y trazabilidad de bienes en guarda',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textoSecundario,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de KPIs métricos compactos
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                KpiCard(
                  title: 'Disponibles',
                  value: '${vm.totalDisponibles}',
                  subtitle: 'Listos para entrega',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: const Color(0xFF059669),
                  onTap: () {
                    vm.setFiltroEstado(Bien.estadoDisponible);
                    onNavigateToTab?.call(1);
                  },
                ),
                KpiCard(
                  title: 'Entregados',
                  value: '${vm.totalEntregados}',
                  subtitle: 'En uso institucional',
                  icon: Icons.assignment_turned_in_outlined,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () {
                    vm.setFiltroEstado(Bien.estadoEntregado);
                    onNavigateToTab?.call(1);
                  },
                ),
                KpiCard(
                  title: 'En Mantenimiento',
                  value: '${vm.totalEnMantenimiento}',
                  subtitle: 'Reportados con daño',
                  icon: Icons.build_circle_outlined,
                  accentColor: const Color(0xFFD97706),
                  onTap: () {
                    vm.setFiltroEstado(Bien.estadoEnMantenimiento);
                    onNavigateToTab?.call(1);
                  },
                ),
                KpiCard(
                  title: 'Dados de Baja',
                  value: '${vm.totalDadosDeBaja}',
                  subtitle: 'Bloqueados permanentemente',
                  icon: Icons.cancel_outlined,
                  accentColor: const Color(0xFFDC2626),
                  onTap: () {
                    vm.setFiltroEstado(Bien.estadoDadoDeBaja);
                    onNavigateToTab?.call(1);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Accesos Rápidos
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primario,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.superficie,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      FormularioEntregaSheet.show(context);
                    },
                    icon: const Icon(Icons.outbox_rounded, size: 16, color: AppTheme.acento),
                    label: const Text('Nueva Entrega', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.superficie,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/bien/formulario');
                    },
                    icon: const Icon(Icons.add_box_outlined, size: 16, color: AppTheme.primario),
                    label: const Text('Nuevo Bien', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.superficie,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      FormularioResponsableSheet.show(context);
                    },
                    icon: const Icon(Icons.person_add_alt_outlined, size: 16, color: Color(0xFF059669)),
                    label: const Text('Responsable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resumen de Entregas Activas (Guarda actual)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Entregas Activas Recientes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primario,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab?.call(2),
                  child: const Text('Ver todas', style: TextStyle(fontSize: 12, color: AppTheme.acento)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (vm.entregasActivas.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.superficie,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borde),
                ),
                child: const Center(
                  child: Text(
                    'No hay entregas pendientes de devolución en guarda.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textoSecundario),
                  ),
                ),
              )
            else
              ...vm.entregasActivas.take(3).map((e) {
                final bien = vm.getBienById(e.bienId);
                final resp = vm.getResponsableById(e.responsableId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.superficie,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borde),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.outbox_rounded, color: AppTheme.acento, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bien?.nombre ?? 'Bien #${e.bienId}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primario),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'A: ${resp?.nombre ?? "Responsable"} • Cant: ${e.cantidad} un.',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        e.fechaEntrega,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
