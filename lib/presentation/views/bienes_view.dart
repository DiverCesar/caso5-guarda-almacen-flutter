import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bien.dart';
import '../theme/app_theme.dart';
import '../viewmodels/almacen_viewmodel.dart';
import '../widgets/bien_card.dart';

class BienesView extends StatelessWidget {
  const BienesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlmacenViewModel>();
    final filtros = ['Todos', ...Bien.estadosValidos];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Bienes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, size: 22),
            tooltip: 'Registrar nuevo bien',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/bien/formulario');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primario,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nuevo Bien', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/bien/formulario');
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await vm.cargarTodo();
        },
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              color: AppTheme.superficie,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => vm.setBusquedaQuery(val),
                decoration: InputDecoration(
                  hintText: 'Buscar por código institucional o nombre...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textoSecundario),
                  suffixIcon: vm.busquedaQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => vm.setBusquedaQuery(''),
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.fondo,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // Chips horizontales de filtrado por estado
            Container(
              color: AppTheme.superficie,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filtros.map((filtro) {
                    final isSelected = vm.filtroEstado == filtro;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(filtro),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textoSecundario,
                        ),
                        backgroundColor: AppTheme.fondo,
                        selectedColor: AppTheme.primario,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primario : AppTheme.borde,
                          ),
                        ),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          vm.setFiltroEstado(filtro);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(color: AppTheme.borde, height: 1),

            // Banner instructivo de gestos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFF1F5F9),
              child: const Row(
                children: [
                  Icon(Icons.swipe_outlined, size: 14, color: AppTheme.textoSecundario),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deslizar der: Nueva Entrega • Deslizar izq: Cambiar estado • Doble tap: Copiar',
                      style: TextStyle(fontSize: 10.5, color: AppTheme.textoSecundario),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de bienes
            Expanded(
              child: vm.cargando && vm.bienes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : vm.bienesFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.borde),
                              const SizedBox(height: 12),
                              Text(
                                vm.busquedaQuery.isNotEmpty
                                    ? 'No se encontraron bienes coincidentes'
                                    : 'No hay bienes en esta categoría',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textoSecundario),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: vm.bienesFiltrados.length,
                          itemBuilder: (context, index) {
                            final bien = vm.bienesFiltrados[index];
                            return BienCard(
                              bien: bien,
                              onTap: () {
                                vm.seleccionarBien(bien);
                                Navigator.pushNamed(context, '/bien/detalle');
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
