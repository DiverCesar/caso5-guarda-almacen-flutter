import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entrega.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'formulario_devolucion_sheet.dart';

class EntregaCard extends StatelessWidget {
  final Entrega entrega;

  const EntregaCard({
    super.key,
    required this.entrega,
  });

  void _abrirDevolucion(BuildContext context) {
    HapticFeedback.lightImpact();
    FormularioDevolucionSheet.show(context, entrega);
  }

  void _mostrarMenuContextual(BuildContext context) {
    HapticFeedback.mediumImpact();
    final vm = context.read<AlmacenViewModel>();
    final bien = vm.getBienById(entrega.bienId);

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
                if (!entrega.devuelto)
                  ListTile(
                    leading: const Icon(Icons.assignment_return_outlined, color: AppTheme.acento),
                    title: const Text('Registrar devolución de bien'),
                    subtitle: const Text('Desliza a la derecha para acceso rápido'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _abrirDevolucion(context);
                    },
                  ),
                if (bien != null)
                  ListTile(
                    leading: const Icon(Icons.copy_rounded, color: AppTheme.primario),
                    title: const Text('Copiar código del bien'),
                    subtitle: Text(bien.codigoInstitucional, style: const TextStyle(fontFamily: 'monospace')),
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: bien.codigoInstitucional));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Código "${bien.codigoInstitucional}" copiado')),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final bien = vm.getBienById(entrega.bienId);
    final responsable = vm.getResponsableById(entrega.responsableId);

    Widget contenidoTarjeta = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entrega.devuelto
              ? AppTheme.borde
              : (entrega.presentaDano ? AppTheme.badgeMantenimientoBorder : AppTheme.borde),
          width: 1,
        ),
      ),
      child: InkWell(
        onLongPress: () => _mostrarMenuContextual(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Tipo de entrega y estado de devolución
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: entrega.tipoEntrega == Entrega.tipoTemporal
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: entrega.tipoEntrega == Entrega.tipoTemporal
                            ? const Color(0xFFBFDBFE)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      'Entrega ${entrega.tipoEntrega}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: entrega.tipoEntrega == Entrega.tipoTemporal
                            ? const Color(0xFF1E40AF)
                            : AppTheme.primario,
                      ),
                    ),
                  ),
                  if (entrega.devuelto)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: entrega.presentaDano ? AppTheme.badgeMantenimientoBg : AppTheme.badgeDisponibleBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: entrega.presentaDano ? AppTheme.badgeMantenimientoBorder : AppTheme.badgeDisponibleBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            entrega.presentaDano ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            size: 13,
                            color: entrega.presentaDano ? AppTheme.badgeMantenimientoText : AppTheme.badgeDisponibleText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entrega.presentaDano ? 'Devuelto con daño' : 'Devuelto',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: entrega.presentaDano ? AppTheme.badgeMantenimientoText : AppTheme.badgeDisponibleText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFF92400E)),
                          SizedBox(width: 4),
                          Text(
                            'Activa (En guarda)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Bien
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bien?.codigoInstitucional ?? 'BIEN-${entrega.bienId}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primario,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bien?.nombre ?? 'Bien no registrado',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primario),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.fondo,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borde),
                    ),
                    child: Text(
                      '${entrega.cantidad} un.',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.acento),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Responsable
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 15, color: AppTheme.textoSecundario),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${responsable?.nombre ?? "Responsable"} • ${responsable?.area ?? ""}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Fecha y Condición
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textoSecundario),
                  const SizedBox(width: 6),
                  Text(
                    'Entregado: ${entrega.fechaEntrega}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.verified_outlined, size: 14, color: AppTheme.textoSecundario),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Condición: ${entrega.condicionEntrega}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (entrega.observacion.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Obs: ${entrega.observacion}',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textoSecundario),
                ),
              ],

              // Si ya fue devuelto, mostrar detalle de devolución
              if (entrega.devuelto) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.fondo,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borde),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_return_outlined, size: 13, color: AppTheme.textoSecundario),
                          const SizedBox(width: 6),
                          Text(
                            'Devuelto el: ${entrega.fechaDevolucion ?? "N/A"}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primario),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Condición al retornar: ${entrega.condicionDevolucion ?? "Sin detalle"}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
                      ),
                      if (entrega.presentaDano) ...[
                        const SizedBox(height: 2),
                        const Text(
                          '⚠ Presentó daño: Estado del bien transferido a "En mantenimiento"',
                          style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Botón rápido de devolución si la entrega sigue activa
              if (!entrega.devuelto) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.acento,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _abrirDevolucion(context),
                      icon: const Icon(Icons.assignment_return_outlined, size: 16),
                      label: const Text('Registrar Devolución', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Si está activa, habilitar Dismissible hacia la derecha para abrir devolución
    if (!entrega.devuelto) {
      return Dismissible(
        key: ValueKey('entrega_${entrega.id}'),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          _abrirDevolucion(context);
          return false; // No quitar de la lista
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.acento,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              Icon(Icons.assignment_return_outlined, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Registrar Devolución',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ),
        child: contenidoTarjeta,
      );
    }

    return contenidoTarjeta;
  }
}
