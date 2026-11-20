import '../../core/errors/exceptions.dart';
import '../entities/bien.dart';
import '../repositories/almacen_repository.dart';

class CambiarEstadoBienUseCase {
  final AlmacenRepository repository;

  CambiarEstadoBienUseCase(this.repository);

  Future<Bien> ejecutar(int bienId, String nuevoEstado) async {
    final bienes = await repository.obtenerBienes();
    final index = bienes.indexWhere((b) => b.id == bienId);
    if (index == -1) {
      throw ValidationException('El bien especificado no existe.');
    }
    final bien = bienes[index];

    // Regla 8: Bloqueo por baja
    if (bien.isDadoDeBaja) {
      throw ValidationException('Un bien con estado "Dado de baja" no puede cambiar de estado.');
    }

    if (!Bien.estadosValidos.contains(nuevoEstado)) {
      throw ValidationException('Estado destino inválido: $nuevoEstado');
    }

    Bien bienActualizado;
    if (nuevoEstado == Bien.estadoDadoDeBaja) {
      bienActualizado = bien.copyWith(
        estado: nuevoEstado,
        cantidadDisponible: 0,
      );
    } else if (nuevoEstado == Bien.estadoEnMantenimiento) {
      bienActualizado = bien.copyWith(
        estado: nuevoEstado,
        cantidadDisponible: 0,
      );
    } else if (nuevoEstado == Bien.estadoDisponible) {
      bienActualizado = bien.copyWith(
        estado: nuevoEstado,
        cantidadDisponible: bien.cantidadTotal,
      );
    } else {
      bienActualizado = bien.copyWith(estado: nuevoEstado);
    }

    return await repository.actualizarBien(bienActualizado);
  }
}
