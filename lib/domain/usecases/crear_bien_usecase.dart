import '../../core/errors/exceptions.dart';
import '../entities/bien.dart';
import '../repositories/almacen_repository.dart';

class CrearBienUseCase {
  final AlmacenRepository repository;

  CrearBienUseCase(this.repository);

  Future<Bien> ejecutar(Bien bien) async {
    // Validar campos obligatorios
    if (bien.codigoInstitucional.trim().isEmpty) {
      throw ValidationException('El código institucional es obligatorio.');
    }
    if (bien.nombre.trim().isEmpty) {
      throw ValidationException('El nombre del bien es obligatorio.');
    }
    if (bien.cantidadTotal <= 0) {
      throw ValidationException('La cantidad total debe ser mayor a 0.');
    }

    // Regla 3: Estados permitidos del bien
    if (!Bien.estadosValidos.contains(bien.estado)) {
      throw ValidationException('Estado inválido. Permitidos: ${Bien.estadosValidos.join(", ")}');
    }

    // Regla 1: Código institucional único
    final bienesExistentes = await repository.obtenerBienes();
    final existeCodigo = bienesExistentes.any(
      (b) => b.codigoInstitucional.trim().toLowerCase() == bien.codigoInstitucional.trim().toLowerCase(),
    );
    if (existeCodigo) {
      throw ValidationException('El código institucional "${bien.codigoInstitucional}" ya está registrado.');
    }

    // Si no se definió cantidadDisponible, se asume igual a cantidadTotal
    final bienAjustado = bien.copyWith(
      codigoInstitucional: bien.codigoInstitucional.trim().toUpperCase(),
      nombre: bien.nombre.trim(),
      cantidadDisponible: bien.cantidadDisponible > 0 ? bien.cantidadDisponible : bien.cantidadTotal,
    );

    return await repository.crearBien(bienAjustado);
  }
}
