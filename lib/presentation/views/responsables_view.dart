import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/formulario_responsable_sheet.dart';

class ResponsablesView extends StatelessWidget {
  const ResponsablesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsables Institucionales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 22),
            tooltip: 'Registrar responsable',
            onPressed: () {
              HapticFeedback.lightImpact();
              FormularioResponsableSheet.show(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primario,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Nuevo Responsable', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onPressed: () {
          HapticFeedback.lightImpact();
          FormularioResponsableSheet.show(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await vm.cargarTodo();
        },
        child: vm.responsables.isEmpty
            ? const Center(child: Text('No hay responsables registrados'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                itemCount: vm.responsables.length,
                itemBuilder: (context, index) {
                  final r = vm.responsables[index];
                  // Bienes asignados activamente a este responsable
                  final entregasActivasResp = vm.entregasActivas.where((e) => e.responsableId == r.id).toList();

                  IconData cargoIcon;
                  Color cargoColor;
                  switch (r.cargo.toLowerCase()) {
                    case 'docente':
                      cargoIcon = Icons.school_outlined;
                      cargoColor = const Color(0xFF2563EB);
                      break;
                    case 'laboratorio':
                      cargoIcon = Icons.biotech_outlined;
                      cargoColor = const Color(0xFF059669);
                      break;
                    case 'responsable de proyecto':
                      cargoIcon = Icons.rocket_launch_outlined;
                      cargoColor = const Color(0xFF7C3AED);
                      break;
                    default:
                      cargoIcon = Icons.business_outlined;
                      cargoColor = const Color(0xFF475569);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.superficie,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borde),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cargoColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(cargoIcon, size: 18, color: cargoColor),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.nombre,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primario,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.area,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.fondo,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.borde),
                                ),
                                child: Text(
                                  r.cargo[0].toUpperCase() + r.cargo.substring(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cargoColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: AppTheme.borde, height: 1),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.contact_mail_outlined, size: 14, color: AppTheme.textoSecundario),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.contacto,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: entregasActivasResp.isNotEmpty
                                      ? const Color(0xFFEFF6FF)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${entregasActivasResp.length} bienes en guarda',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: entregasActivasResp.isNotEmpty
                                        ? const Color(0xFF1E40AF)
                                        : AppTheme.textoSecundario,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
