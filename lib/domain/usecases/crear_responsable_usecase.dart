import '../../core/errors/exceptions.dart';
import '../entities/responsable.dart';
import '../repositories/almacen_repository.dart';

class CrearResponsableUseCase {
  final AlmacenRepository repository;

  CrearResponsableUseCase(this.repository);

  Future<Responsable> ejecutar(Responsable responsable) async {
    if (responsable.nombre.trim().isEmpty) {
      throw ValidationException('El nombre del responsable es obligatorio.');
    }
    if (responsable.cargo.trim().isEmpty) {
      throw ValidationException('El cargo es obligatorio.');
    }
    if (responsable.area.trim().isEmpty) {
      throw ValidationException('El área o departamento es obligatorio.');
    }

    return await repository.crearResponsable(
      responsable.copyWith(
        nombre: responsable.nombre.trim(),
        cargo: responsable.cargo.trim(),
        area: responsable.area.trim(),
        contacto: responsable.contacto.trim(),
      ),
    );
  }
}
