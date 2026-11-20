import '../../core/errors/exceptions.dart';
import '../entities/bien.dart';
import '../repositories/almacen_repository.dart';

class ActualizarBienUseCase {
  final AlmacenRepository repository;

  ActualizarBienUseCase(this.repository);

  Future<Bien> ejecutar(Bien bien) async {
    if (bien.id == null) {
      throw ValidationException('Identificador de bien no válido para actualización.');
    }

    final bienes = await repository.obtenerBienes();
    final index = bienes.indexWhere((b) => b.id == bien.id);
    if (index == -1) {
      throw ValidationException('El bien especificado no existe.');
    }
    final bienActual = bienes[index];

    // Regla 8: Bloqueo por baja
    if (bienActual.isDadoDeBaja && bien.estado != Bien.estadoDadoDeBaja) {
      throw ValidationException('Un bien "Dado de baja" no puede volver a activarse ni editarse.');
    }

    // Regla 1: Código institucional único
    final codigoDuplicado = bienes.any(
      (b) => b.id != bien.id &&
          b.codigoInstitucional.trim().toLowerCase() == bien.codigoInstitucional.trim().toLowerCase(),
    );
    if (codigoDuplicado) {
      throw ValidationException('Ya existe otro bien con el código "${bien.codigoInstitucional}".');
    }

    // Regla 3: Estados permitidos
    if (!Bien.estadosValidos.contains(bien.estado)) {
      throw ValidationException('Estado inválido. Permitidos: ${Bien.estadosValidos.join(", ")}');
    }

    if (bien.cantidadTotal < bien.cantidadDisponible) {
      throw ValidationException('La cantidad disponible no puede exceder la cantidad total.');
    }

    return await repository.actualizarBien(bien);
  }
}
