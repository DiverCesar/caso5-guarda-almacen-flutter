import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/responsable.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import 'custom_text_field.dart';

class FormularioResponsableSheet extends StatefulWidget {
  const FormularioResponsableSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FormularioResponsableSheet(),
    );
  }

  @override
  State<FormularioResponsableSheet> createState() => _FormularioResponsableSheetState();
}

class _FormularioResponsableSheetState extends State<FormularioResponsableSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _areaController = TextEditingController();
  final _contactoController = TextEditingController();

  String _cargo = 'docente';
  bool _guardando = false;

  final List<String> _cargos = [
    'docente',
    'laboratorio',
    'oficina',
    'responsable de proyecto',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _areaController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    HapticFeedback.mediumImpact();

    final vm = context.read<AlmacenViewModel>();
    final nuevo = Responsable(
      nombre: _nombreController.text.trim(),
      cargo: _cargo,
      area: _areaController.text.trim(),
      contacto: _contactoController.text.trim(),
    );

    final ok = await vm.agregarResponsable(nuevo);

    if (mounted) {
      setState(() => _guardando = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.mensajeExito ?? 'Responsable agregado'),
            backgroundColor: const Color(0xFF065F46),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Error al registrar responsable'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.acento, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrar Responsable',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primario),
                          ),
                          Text(
                            'Docentes, laboratorios, oficinas y proyectos',
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

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _nombreController,
                          label: 'Nombre completo o denominación *',
                          hint: 'Ej: Ing. Carlos Mendoza o Lab. de Redes',
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Cargo o Tipo de Entidad *',
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
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _cargo,
                              items: _cargos.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(
                                    c[0].toUpperCase() + c.substring(1),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _cargo = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _areaController,
                          label: 'Área / Departamento institucional *',
                          hint: 'Ej: Sistemas e Informática, Dirección Académica...',
                          prefixIcon: Icons.apartment_rounded,
                          validator: (v) => v == null || v.trim().isEmpty ? 'El área es obligatoria' : null,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _contactoController,
                          label: 'Correo electrónico o teléfono institucional *',
                          hint: 'Ej: correo@universidad.edu.ec o 0991234567',
                          prefixIcon: Icons.contact_mail_outlined,
                          validator: (v) => v == null || v.trim().isEmpty ? 'El contacto es obligatorio' : null,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            icon: _guardando
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_rounded, size: 18),
                            label: Text(_guardando ? 'Guardando...' : 'Guardar Responsable'),
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
