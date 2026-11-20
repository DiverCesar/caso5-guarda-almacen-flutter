import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/custom_text_field.dart';

class FormularioBienView extends StatefulWidget {
  const FormularioBienView({super.key});

  @override
  State<FormularioBienView> createState() => _FormularioBienViewState();
}

class _FormularioBienViewState extends State<FormularioBienView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codigoController;
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _cantidadTotalController;

  String _estado = Bien.estadoDisponible;
  bool _esEdicion = false;
  Bien? _bienOriginal;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AlmacenViewModel>();
    _bienOriginal = vm.bienSeleccionado;
    _esEdicion = _bienOriginal != null && ModalRoute.of(context)?.settings.arguments != 'crear';

    _codigoController = TextEditingController(text: _esEdicion ? _bienOriginal!.codigoInstitucional : '');
    _nombreController = TextEditingController(text: _esEdicion ? _bienOriginal!.nombre : '');
    _descripcionController = TextEditingController(text: _esEdicion ? _bienOriginal!.descripcion : '');
    _cantidadTotalController = TextEditingController(text: _esEdicion ? _bienOriginal!.cantidadTotal.toString() : '1');
    if (_esEdicion) {
      _estado = _bienOriginal!.estado;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadTotalController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    HapticFeedback.mediumImpact();

    final vm = context.read<AlmacenViewModel>();
    final cantidad = int.tryParse(_cantidadTotalController.text.trim()) ?? 1;

    bool exito;
    if (_esEdicion && _bienOriginal != null) {
      final bienEditado = _bienOriginal!.copyWith(
        codigoInstitucional: _codigoController.text.trim().toUpperCase(),
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidadTotal: cantidad,
        estado: _estado,
      );
      exito = await vm.editarBien(bienEditado);
    } else {
      final nuevoBien = Bien(
        codigoInstitucional: _codigoController.text.trim().toUpperCase(),
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        cantidadTotal: cantidad,
        cantidadDisponible: cantidad,
        estado: _estado,
      );
      exito = await vm.agregarBien(nuevoBien);
    }

    if (mounted) {
      setState(() => _guardando = false);
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.mensajeExito ?? 'Operación realizada con éxito'),
            backgroundColor: const Color(0xFF065F46),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Error en validación'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Bien' : 'Nuevo Bien Institucional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Código institucional (Regla 1: Único)
              CustomTextField(
                controller: _codigoController,
                label: 'Código Institucional * (Único)',
                hint: 'Ej: EPN-PRJ-001 o LAB-OSC-014',
                prefixIcon: Icons.qr_code_2_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El código es obligatorio';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nombre
              CustomTextField(
                controller: _nombreController,
                label: 'Nombre o denominación del bien *',
                hint: 'Ej: Proyector Epson PowerLite E20',
                prefixIcon: Icons.devices_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              CustomTextField(
                controller: _descripcionController,
                label: 'Descripción / Características técnicas',
                hint: 'Detalles técnicos, marca, modelo, especificaciones...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Cantidad y Estado en fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _cantidadTotalController,
                      label: 'Cantidad Total *',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.numbers_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = int.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Mayor a 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado Inicial *',
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
                              value: _estado,
                              items: Bien.estadosValidos.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _estado = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nota de validación institucional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.fondo,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borde),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reglas de Validación Institucional:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primario),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• El código institucional debe ser estrictamente único.\n'
                      '• Un bien dado de baja no podrá modificarse para re-entregas.\n'
                      '• La disponibilidad se inicializará con la cantidad total.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textoSecundario, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_guardando ? 'Guardando...' : (_esEdicion ? 'Actualizar Bien' : 'Registrar Bien')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
