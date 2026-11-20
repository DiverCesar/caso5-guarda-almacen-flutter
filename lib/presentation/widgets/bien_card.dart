import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'estado_badge.dart';
import 'formulario_entrega_sheet.dart';

class BienCard extends StatelessWidget {
  final Bien bien;
  final VoidCallback onTap;

  const BienCard({
    super.key,
    required this.bien,
    required this.onTap,
  });

  void _copiarCodigo(BuildContext context) {
    Clipboard.setData(ClipboardData(text: bien.codigoInstitucional));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código "${bien.codigoInstitucional}" copiado al portapapeles'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarMenuContextual(BuildContext context) {
    HapticFeedback.mediumImpact();
    final vm = context.read<AlmacenViewModel>();

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
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.borde,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: AppTheme.acento),
                  title: const Text('Copiar código institucional'),
                  subtitle: Text(bien.codigoInstitucional, style: const TextStyle(fontFamily: 'monospace')),
                  onTap: () {
                    Navigator.pop(ctx);
                    _copiarCodigo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: AppTheme.primario),
                  title: const Text('Ver detalle e historial'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onTap();
                  },
                ),
                if (bien.isDisponible)
                  ListTile(
                    leading: const Icon(Icons.outbox_rounded, color: Color(0xFF059669)),
                    title: const Text('Registrar entrega rápida'),
                    onTap: () {
                      Navigator.pop(ctx);
                      FormularioEntregaSheet.show(context, bienPreseleccionado: bien);
                    },
                  ),
                if (!bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.build_circle_outlined, color: Color(0xFFD97706)),
                    title: const Text('Enviar a mantenimiento'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmarCambioEstado(context, vm, Bien.estadoEnMantenimiento);
                    },
                  ),
                if (!bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                    title: const Text('Dar de baja bien institucional'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmarCambioEstado(context, vm, Bien.estadoDadoDeBaja);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarCambioEstado(BuildContext context, AlmacenViewModel vm, String nuevoEstado) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Cambiar estado a "$nuevoEstado"'),
        content: Text(
          nuevoEstado == Bien.estadoDadoDeBaja
              ? '¿Está seguro de dar de baja este bien? Esta acción es irreversible según las reglas de negocio (Regla 8).'
              : '¿Desea cambiar el estado del bien a $nuevoEstado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: nuevoEstado == Bien.estadoDadoDeBaja ? const Color(0xFFDC2626) : AppTheme.primario,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await vm.cambiarEstado(bien.id!, nuevoEstado);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? (vm.mensajeExito ?? 'Estado actualizado') : (vm.error ?? 'Error')),
                    backgroundColor: ok ? const Color(0xFF065F46) : const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AlmacenViewModel>();

    return Dismissible(
      key: ValueKey('bien_${bien.id}_${bien.codigoInstitucional}'),
      // Swipe Derecha -> Nueva Entrega
      // Swipe Izquierda -> Cambiar Estado
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Deslizar a la derecha
          if (bien.isDisponible) {
            HapticFeedback.lightImpact();
            FormularioEntregaSheet.show(context, bienPreseleccionado: bien);
          } else {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  bien.isDadoDeBaja
                      ? 'Regla 8: El bien está "Dado de baja" y no puede entregarse.'
                      : 'El bien está en estado "${bien.estado}". Solo bienes "Disponibles" pueden entregarse.',
                ),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
          return false; // No eliminar la tarjeta
        } else {
          // Deslizar a la izquierda
          if (bien.isDadoDeBaja) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Regla 8: Un bien "Dado de baja" no puede cambiar de estado.'),
                backgroundColor: Color(0xFFDC2626),
              ),
            );
            return false;
          }
          HapticFeedback.mediumImpact();
          _mostrarOpcionesCambioEstado(context, vm);
          return false;
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.outbox_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Nueva Entrega',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD97706),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Cambiar Estado',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            SizedBox(width: 8),
            Icon(Icons.tune_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borde, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _mostrarMenuContextual(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Código y Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Doble tap para copiar código
                    GestureDetector(
                      onDoubleTap: () => _copiarCodigo(context),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'bien_icon_${bien.id}',
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.fondo,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.borde),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primario),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Doble tap para copiar código',
                            child: Text(
                              bien.codigoInstitucional,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.primario,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    EstadoBadge(estado: bien.estado),
                  ],
                ),
                const SizedBox(height: 10),

                // Nombre
                Text(
                  bien.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primario,
                  ),
                ),
                if (bien.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bien.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textoSecundario,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Fila inferior: Disponibilidad y Barra de Stock
                Row(
                  children: [
                    Text(
                      'Stock: ${bien.cantidadDisponible} / ${bien.cantidadTotal} un.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: bien.cantidadDisponible == 0 ? AppTheme.textoSecundario : const Color(0xFF065F46),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: bien.cantidadTotal > 0 ? (bien.cantidadDisponible / bien.cantidadTotal) : 0,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: bien.cantidadDisponible == 0
                              ? const Color(0xFF94A3B8)
                              : (bien.cantidadDisponible < bien.cantidadTotal ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarOpcionesCambioEstado(BuildContext context, AlmacenViewModel vm) {
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
                    'Cambio rápido de estado',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primario),
                  ),
                ),
                const Divider(color: AppTheme.borde),
                if (bien.estado != Bien.estadoDisponible && !bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                    title: const Text('Reactivar como Disponible'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmarCambioEstado(context, vm, Bien.estadoDisponible);
                    },
                  ),
                if (bien.estado != Bien.estadoEnMantenimiento && !bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.build_circle_outlined, color: Color(0xFFD97706)),
                    title: const Text('Enviar a Mantenimiento'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmarCambioEstado(context, vm, Bien.estadoEnMantenimiento);
                    },
                  ),
                if (!bien.isDadoDeBaja)
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                    title: const Text('Dar de baja definitivamente (Regla 8)'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmarCambioEstado(context, vm, Bien.estadoDadoDeBaja);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
