import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/entrega_card.dart';
import '../widgets/estado_badge.dart';
import '../widgets/formulario_entrega_sheet.dart';

class DetalleBienView extends StatelessWidget {
  const DetalleBienView({super.key});

  void _copiarCodigo(BuildContext context, String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código "$codigo" copiado al portapapeles')),
    );
  }

  void _mostrarDialogoCambiarEstado(BuildContext context, Bien bien, AlmacenViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cambiar estado del bien',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primario),
                  ),
                ),
                const Divider(color: AppTheme.borde),
                if (bien.estado != Bien.estadoDisponible && !bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                    title: const Text('Reactivar como Disponible'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _confirmarYEjecutar(context, vm, bien.id!, Bien.estadoDisponible);
                    },
                  ),
                if (bien.estado != Bien.estadoEnMantenimiento && !bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.build_circle_outlined, color: Color(0xFFD97706)),
                    title: const Text('Enviar a Mantenimiento'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _confirmarYEjecutar(context, vm, bien.id!, Bien.estadoEnMantenimiento);
                    },
                  ),
                if (!bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                    title: const Text('Dar de baja (Regla 8: Irreversible)'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _confirmarYEjecutar(context, vm, bien.id!, Bien.estadoDadoDeBaja);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarYEjecutar(BuildContext context, AlmacenViewModel vm, int id, String estado) async {
    final ok = await vm.cambiarEstado(id, estado);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? (vm.mensajeExito ?? 'Estado actualizado') : (vm.error ?? 'Error')),
          backgroundColor: ok ? const Color(0xFF065F46) : const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final bien = vm.bienSeleccionado;

    if (bien == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Bien')),
        body: const Center(child: Text('No hay bien seleccionado')),
      );
    }

    final historial = vm.getHistorialBien(bien.id ?? -1);

    return Scaffold(
      appBar: AppBar(
        title: Text(bien.codigoInstitucional),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copiar código',
            onPressed: () => _copiarCodigo(context, bien.codigoInstitucional),
          ),
          if (!bien.isDadoDeBaja)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Editar bien',
              onPressed: () {
                Navigator.pushNamed(context, '/bien/formulario');
              },
            ),
        ],
      ),
      bottomNavigationBar: bien.isDisponible
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.superficie,
                border: Border(top: BorderSide(color: AppTheme.borde)),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  FormularioEntregaSheet.show(context, bienPreseleccionado: bien);
                },
                icon: const Icon(Icons.outbox_rounded, size: 18),
                label: const Text('Registrar Nueva Entrega'),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await vm.cargarTodo();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cabecera con Hero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.superficie,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'bien_icon_${bien.id}',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.fondo,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borde),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, size: 28, color: AppTheme.primario),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onDoubleTap: () => _copiarCodigo(context, bien.codigoInstitucional),
                              child: Text(
                                bien.codigoInstitucional,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primario,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            EstadoBadge(estado: bien.estado),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    bien.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primario,
                    ),
                  ),
                  if (bien.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bien.descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textoSecundario,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borde),
                  const SizedBox(height: 10),

                  // Stock e indicadores
                  Row(
                    children: [
                      Expanded(
                        child: _InfoPill(
                          label: 'Total Registrado',
                          valor: '${bien.cantidadTotal} un.',
                          color: AppTheme.primario,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoPill(
                          label: 'Disponible en Guarda',
                          valor: '${bien.cantidadDisponible} un.',
                          color: bien.cantidadDisponible > 0 ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                  if (!bien.isDadoDeBaja) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _mostrarDialogoCambiarEstado(context, bien, vm),
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('Gestionar Estado', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                  if (bien.isDadoDeBaja) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.badgeBajaBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.badgeBajaBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_rounded, size: 16, color: AppTheme.badgeBajaText),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Regla 8: Bien dado de baja. Bloqueado de manera permanente para entregas.',
                              style: TextStyle(fontSize: 11, color: AppTheme.badgeBajaText, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Historial de entregas de este bien
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 18, color: AppTheme.primario),
                const SizedBox(width: 6),
                const Text(
                  'Historial de Asignaciones y Entregas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primario,
                  ),
                ),
                const Spacer(),
                Text(
                  '${historial.length} registros',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (historial.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.superficie,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borde),
                ),
                child: const Center(
                  child: Text(
                    'No hay registros de entregas previas para este bien.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textoSecundario),
                  ),
                ),
              )
            else
              ...historial.map((e) => EntregaCard(entrega: e)),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.fondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
