import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/responsable.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'custom_text_field.dart';

class FormularioEntregaSheet extends StatefulWidget {
  final Bien? bienPreseleccionado;

  const FormularioEntregaSheet({
    super.key,
    this.bienPreseleccionado,
  });

  static Future<void> show(BuildContext context, {Bien? bienPreseleccionado}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormularioEntregaSheet(bienPreseleccionado: bienPreseleccionado),
    );
  }

  @override
  State<FormularioEntregaSheet> createState() => _FormularioEntregaSheetState();
}

class _FormularioEntregaSheetState extends State<FormularioEntregaSheet> {
  final _formKey = GlobalKey<FormState>();

  Bien? _bienSeleccionado;
  Responsable? _responsableSeleccionado;
  String _tipoEntrega = Entrega.tipoTemporal;

  late final TextEditingController _fechaController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _observacionController;
  late final TextEditingController _condicionController;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _bienSeleccionado = widget.bienPreseleccionado;

    final hoy = DateTime.now();
    final fechaStr = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    _fechaController = TextEditingController(text: fechaStr);
    _cantidadController = TextEditingController(text: '1');
    _observacionController = TextEditingController();
    _condicionController = TextEditingController(text: 'Óptimo');
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _cantidadController.dispose();
    _observacionController.dispose();
    _condicionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_bienSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un bien del inventario')),
      );
      return;
    }

    if (_responsableSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un responsable institucional')),
      );
      return;
    }

    setState(() => _guardando = true);
    HapticFeedback.mediumImpact();

    final vm = context.read<AlmacenViewModel>();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 1;

    final nuevaEntrega = Entrega(
      bienId: _bienSeleccionado!.id!,
      responsableId: _responsableSeleccionado!.id!,
      tipoEntrega: _tipoEntrega,
      fechaEntrega: _fechaController.text.trim(),
      cantidad: cantidad,
      observacion: _observacionController.text.trim(),
      condicionEntrega: _condicionController.text.trim(),
    );

    final ok = await vm.registrarEntrega(nuevaEntrega);

    if (mounted) {
      setState(() => _guardando = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.mensajeExito ?? 'Entrega registrada'),
            backgroundColor: const Color(0xFF065F46),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Error al registrar entrega'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final bienesDisponibles = vm.bienes.where((b) => b.isDisponible).toList();
    final responsables = vm.responsables;

    // Si había un bien preseleccionado, verificar que aún existe en la lista
    if (_bienSeleccionado != null && !bienesDisponibles.any((b) => b.id == _bienSeleccionado!.id)) {
      if (bienesDisponibles.isNotEmpty) {
        _bienSeleccionado = bienesDisponibles.first;
      }
    } else if (_bienSeleccionado == null && bienesDisponibles.isNotEmpty) {
      _bienSeleccionado = bienesDisponibles.first;
    }

    if (_responsableSeleccionado == null && responsables.isNotEmpty) {
      _responsableSeleccionado = responsables.first;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.superficie,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                      child: const Icon(Icons.outbox_rounded, color: AppTheme.acento, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva Entrega de Bien',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primario),
                          ),
                          Text(
                            'Asignación en guarda de almacén',
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
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de Bien (Solo Disponibles - Regla 2)
                        const Text(
                          'Bien a entregar * (Solo disponibles)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primario),
                        ),
                        const SizedBox(height: 6),
                        if (bienesDisponibles.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.badgeBajaBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.badgeBajaBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppTheme.badgeBajaText, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No hay bienes disponibles en almacén para entregar.',
                                    style: TextStyle(fontSize: 12, color: AppTheme.badgeBajaText),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.superficie,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borde),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Bien>(
                                isExpanded: true,
                                value: _bienSeleccionado,
                                items: bienesDisponibles.map((b) {
                                  return DropdownMenuItem<Bien>(
                                    value: b,
                                    child: Row(
                                      children: [
                                        Text(
                                          b.codigoInstitucional,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            b.nombre,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          'Disp: ${b.cantidadDisponible}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF065F46),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _bienSeleccionado = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Selector de Responsable (Regla 4)
                        const Text(
                          'Responsable asignado * (Obligatorio)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primario),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.superficie,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borde),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Responsable>(
                              isExpanded: true,
                              value: _responsableSeleccionado,
                              hint: const Text('Seleccionar responsable', style: TextStyle(fontSize: 13)),
                              items: responsables.map((r) {
                                return DropdownMenuItem<Responsable>(
                                  value: r,
                                  child: Text(
                                    '${r.nombre} (${r.cargo} - ${r.area})',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _responsableSeleccionado = val;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tipo de entrega y Cantidad en fila
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tipo de entrega
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tipo de Entrega *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primario),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.superficie,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppTheme.borde),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _tipoEntrega,
                                        items: const [
                                          DropdownMenuItem(value: Entrega.tipoTemporal, child: Text('Temporal', style: TextStyle(fontSize: 13))),
                                          DropdownMenuItem(value: Entrega.tipoDefinitiva, child: Text('Definitiva', style: TextStyle(fontSize: 13))),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) setState(() => _tipoEntrega = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Cantidad (Regla 6)
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                controller: _cantidadController,
                                label: 'Cantidad * (Stock disp: ${_bienSeleccionado?.cantidadDisponible ?? 0})',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.numbers_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Requerido';
                                  final n = int.tryParse(v.trim());
                                  if (n == null || n <= 0) return 'Mayor a 0';
                                  if (_bienSeleccionado != null && n > _bienSeleccionado!.cantidadDisponible) {
                                    return 'Máx ${_bienSeleccionado!.cantidadDisponible}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fecha de entrega
                        CustomTextField(
                          controller: _fechaController,
                          label: 'Fecha de Entrega *',
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
                          validator: (v) => v == null || v.trim().isEmpty ? 'La fecha es requerida' : null,
                        ),
                        const SizedBox(height: 16),

                        // Condición de entrega (Regla 5)
                        CustomTextField(
                          controller: _condicionController,
                          label: 'Condición del bien al entregar * (Regla 5)',
                          hint: 'Ej: Óptimo, Con desgaste leve, En caja original...',
                          prefixIcon: Icons.check_circle_outline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese la condición inicial del bien' : null,
                        ),
                        const SizedBox(height: 16),

                        // Observación de entrega (Regla 5)
                        CustomTextField(
                          controller: _observacionController,
                          label: 'Observación y justificación institucional * (Regla 5)',
                          hint: 'Detalle el motivo, proyecto o práctica para la cual se entrega el bien',
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 2,
                          validator: (v) => v == null || v.trim().isEmpty ? 'La observación es obligatoria' : null,
                        ),
                        const SizedBox(height: 16),

                        // Regla 7: Mensaje informativo de stock y estado
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeEntregadoBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.badgeEntregadoBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppTheme.badgeEntregadoText),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Regla 7: El stock se descontará automáticamente. Si la disponibilidad llega a 0, el estado del bien pasará a "Entregado".',
                                  style: TextStyle(fontSize: 11, color: AppTheme.badgeEntregadoText),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de guardar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardando || bienesDisponibles.isEmpty ? null : _guardar,
                            icon: _guardando
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.outbox_rounded, size: 18),
                            label: Text(_guardando ? 'Guardando...' : 'Registrar Entrega'),
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
