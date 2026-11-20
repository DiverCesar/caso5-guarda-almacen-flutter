import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entrega.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'custom_text_field.dart';

class FormularioDevolucionSheet extends StatefulWidget {
  final Entrega entrega;

  const FormularioDevolucionSheet({
    super.key,
    required this.entrega,
  });

  static Future<void> show(BuildContext context, Entrega entrega) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormularioDevolucionSheet(entrega: entrega),
    );
  }

  @override
  State<FormularioDevolucionSheet> createState() => _FormularioDevolucionSheetState();
}

class _FormularioDevolucionSheetState extends State<FormularioDevolucionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _condicionController;
  late final TextEditingController _fechaController;
  bool _presentaDano = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    final fechaStr = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    _fechaController = TextEditingController(text: fechaStr);
    _condicionController = TextEditingController(text: 'En buen estado general');
  }

  @override
  void dispose() {
    _condicionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    HapticFeedback.mediumImpact();

    final vm = context.read<AlmacenViewModel>();
    final ok = await vm.registrarDevolucion(
      entregaId: widget.entrega.id!,
      condicionDevolucion: _condicionController.text.trim(),
      presentaDano: _presentaDano,
      fechaDevolucion: _fechaController.text.trim(),
    );

    if (mounted) {
      setState(() => _guardando = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.mensajeExito ?? 'Devolución procesada'),
            backgroundColor: _presentaDano ? AppTheme.badgeMantenimientoText : const Color(0xFF065F46),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Error al procesar devolución'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final bien = vm.getBienById(widget.entrega.bienId);
    final responsable = vm.getResponsableById(widget.entrega.responsableId);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.superficie,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Indicador de arrastre
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borde,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Encabezado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.acento.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment_return_outlined, color: AppTheme.acento, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrar Devolución',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primario),
                          ),
                          Text(
                            'Control de retorno a guarda de almacén',
                            style: TextStyle(fontSize: 12, color: AppTheme.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppTheme.textoSecundario),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.borde, height: 20),

              // Formulario
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarjeta resumen del bien a devolver
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.fondo,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borde),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    bien?.codigoInstitucional ?? 'BIEN-${widget.entrega.bienId}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppTheme.primario,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Cant: ${widget.entrega.cantidad} un.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppTheme.acento,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bien?.nombre ?? 'Bien no identificado',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primario),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Responsable: ${responsable?.nombre ?? "Desconocido"} (${responsable?.area ?? ""})',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textoSecundario),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fecha de devolución
                        CustomTextField(
                          controller: _fechaController,
                          label: 'Fecha de Devolución *',
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              _fechaController.text =
                                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                            }
                          },
                          validator: (v) => v == null || v.trim().isEmpty ? 'La fecha es obligatoria' : null,
                        ),
                        const SizedBox(height: 16),

                        // Condición de devolución (Obligatorio - Regla 9)
                        CustomTextField(
                          controller: _condicionController,
                          label: 'Condición en la que se devuelve * (Regla 9)',
                          hint: 'Ej: Óptimo, Con desgaste leve, Carcasa rota...',
                          prefixIcon: Icons.checklist_rounded,
                          maxLines: 2,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Debe registrar la condición del bien' : null,
                        ),
                        const SizedBox(height: 16),

                        // Switch ¿Presenta daño? (Regla 10)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _presentaDano ? AppTheme.badgeMantenimientoBg : AppTheme.superficie,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _presentaDano ? AppTheme.badgeMantenimientoBorder : AppTheme.borde,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 20,
                                    color: _presentaDano ? AppTheme.badgeMantenimientoText : AppTheme.textoSecundario,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      '¿El bien presenta algún daño o avería?',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primario),
                                    ),
                                  ),
                                  Switch(
                                    value: _presentaDano,
                                    activeThumbColor: AppTheme.badgeMantenimientoText,
                                    activeTrackColor: AppTheme.badgeMantenimientoBorder,
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _presentaDano = val);
                                    },
                                  ),
                                ],
                              ),
                              if (_presentaDano) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  'Regla 10: Al marcar daño, el bien pasará automáticamente a estado "En mantenimiento", bloqueando nuevas entregas hasta su reparación.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.badgeMantenimientoText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de acción
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            icon: _guardando
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: Text(_guardando ? 'Procesando...' : 'Confirmar Devolución'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
