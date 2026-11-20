import '../../core/errors/exceptions.dart';
import '../entities/bien.dart';
import '../entities/entrega.dart';
import '../repositories/almacen_repository.dart';

class RegistrarEntregaUseCase {
  final AlmacenRepository repository;

  RegistrarEntregaUseCase(this.repository);

  Future<Entrega> ejecutar(Entrega entrega) async {
    // Regla 5: Campos obligatorios de entrega
    if (entrega.fechaEntrega.trim().isEmpty) {
      throw ValidationException('La fecha de entrega es obligatoria.');
    }
    if (entrega.cantidad <= 0) {
      throw ValidationException('La cantidad debe ser mayor a 0.');
    }
    if (entrega.observacion.trim().isEmpty) {
      throw ValidationException('La observación de la entrega es obligatoria.');
    }
    if (entrega.condicionEntrega.trim().isEmpty) {
      throw ValidationException('La condición del bien al entregarse es obligatoria.');
    }

    // Regla 4: Asociación obligatoria con responsable existente
    final responsables = await repository.obtenerResponsables();
    final existeResponsable = responsables.any((r) => r.id == entrega.responsableId);
    if (!existeResponsable) {
      throw ValidationException('El responsable seleccionado no existe en el sistema.');
    }

    // Verificar bien existente
    final bienes = await repository.obtenerBienes();
    final bienIndex = bienes.indexWhere((b) => b.id == entrega.bienId);
    if (bienIndex == -1) {
      throw ValidationException('El bien seleccionado no existe en el inventario.');
    }
    final bien = bienes[bienIndex];

    // Regla 8: Bloqueo por baja
    if (bien.isDadoDeBaja) {
      throw ValidationException('El bien está "Dado de baja" y no puede volver a entregarse.');
    }

    // Regla 2: Solo bienes disponibles
    if (bien.estado != Bien.estadoDisponible) {
      throw ValidationException('El bien no está disponible para entrega (Estado actual: ${bien.estado}).');
    }

    // Regla 6: Control de stock
    if (entrega.cantidad > bien.cantidadDisponible) {
      throw ValidationException(
        'Stock insuficiente. Cantidad solicitada: ${entrega.cantidad}, disponible: ${bien.cantidadDisponible}.',
      );
    }

    // Regla 7: Actualización automática de disponibilidad
    final nuevaCantidadDisponible = bien.cantidadDisponible - entrega.cantidad;
    final nuevoEstado = nuevaCantidadDisponible == 0 ? Bien.estadoEntregado : Bien.estadoDisponible;

    final bienActualizado = bien.copyWith(
      cantidadDisponible: nuevaCantidadDisponible,
      estado: nuevoEstado,
    );

    // Persistir entrega y actualizar bien
    final entregaGuardada = await repository.registrarEntrega(entrega);
    await repository.actualizarBien(bienActualizado);

    return entregaGuardada;
  }
}
