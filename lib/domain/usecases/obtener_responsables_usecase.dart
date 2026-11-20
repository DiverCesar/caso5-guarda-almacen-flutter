import '../entities/responsable.dart';
import '../repositories/almacen_repository.dart';

class ObtenerResponsablesUseCase {
  final AlmacenRepository repository;

  ObtenerResponsablesUseCase(this.repository);

  Future<List<Responsable>> ejecutar() async {
    return await repository.obtenerResponsables();
  }
}
