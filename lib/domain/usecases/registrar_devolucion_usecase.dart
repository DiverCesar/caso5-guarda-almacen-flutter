import '../../core/errors/exceptions.dart';
import '../entities/bien.dart';
import '../entities/entrega.dart';
import '../repositories/almacen_repository.dart';

class RegistrarDevolucionUseCase {
  final AlmacenRepository repository;

  RegistrarDevolucionUseCase(this.repository);

  Future<Entrega> ejecutar({
    required int entregaId,
    required String condicionDevolucion,
    required bool presentaDano,
    required String fechaDevolucion,
  }) async {
    // Regla 9: Exigiendo obligatoriamente registrar su condicionDevolucion
    if (condicionDevolucion.trim().isEmpty) {
      throw ValidationException('La condición del bien al devolverlo es obligatoria.');
    }
    if (fechaDevolucion.trim().isEmpty) {
      throw ValidationException('La fecha de devolución es obligatoria.');
    }

    final entregas = await repository.obtenerEntregas();
    final entregaIndex = entregas.indexWhere((e) => e.id == entregaId);
    if (entregaIndex == -1) {
      throw ValidationException('La entrega especificada no existe.');
    }
    final entrega = entregas[entregaIndex];

    if (entrega.devuelto) {
      throw ValidationException('Esta entrega ya fue devuelta previamente.');
    }

    final bienes = await repository.obtenerBienes();
    final bienIndex = bienes.indexWhere((b) => b.id == entrega.bienId);
    if (bienIndex == -1) {
      throw ValidationException('El bien asociado a esta entrega no existe.');
    }
    final bien = bienes[bienIndex];

    // Regla 10 y Regla 9:
    Bien bienActualizado;
    if (presentaDano) {
      // Regla 10: Si al registrar una devolución se indica que presenta daño,
      // su estado debe cambiar automáticamente a "En mantenimiento" impidiendo nuevas entregas
      bienActualizado = bien.copyWith(
        estado: Bien.estadoEnMantenimiento,
      );
    } else {
      // Regla 9: Al devolverlo sin daño, sumar la cantidad devuelta a cantidadDisponible
      // y restaurar el estado a Disponible
      final nuevaDisponibilidad = (bien.cantidadDisponible + entrega.cantidad).clamp(0, bien.cantidadTotal);
      bienActualizado = bien.copyWith(
        cantidadDisponible: nuevaDisponibilidad,
        estado: Bien.estadoDisponible,
      );
    }

    // Actualizar entrega y bien
    final entregaActualizada = await repository.registrarDevolucion(
      entregaId: entregaId,
      condicionDevolucion: condicionDevolucion.trim(),
      presentaDano: presentaDano,
      fechaDevolucion: fechaDevolucion.trim(),
    );

    await repository.actualizarBien(bienActualizado);

    return entregaActualizada;
  }
}
