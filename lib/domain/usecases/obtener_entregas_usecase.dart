import '../entities/entrega.dart';
import '../repositories/almacen_repository.dart';

class ObtenerEntregasUseCase {
  final AlmacenRepository repository;

  ObtenerEntregasUseCase(this.repository);

  Future<List<Entrega>> ejecutar() async {
    return await repository.obtenerEntregas();
  }
}
