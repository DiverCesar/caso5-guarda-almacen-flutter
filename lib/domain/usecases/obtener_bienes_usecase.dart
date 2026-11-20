import '../entities/bien.dart';
import '../repositories/almacen_repository.dart';

class ObtenerBienesUseCase {
  final AlmacenRepository repository;

  ObtenerBienesUseCase(this.repository);

  Future<List<Bien>> ejecutar() async {
    return await repository.obtenerBienes();
  }
}
