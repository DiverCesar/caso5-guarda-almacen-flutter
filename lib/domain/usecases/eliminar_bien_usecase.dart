import '../repositories/almacen_repository.dart';

class EliminarBienUseCase {
  final AlmacenRepository repository;

  EliminarBienUseCase(this.repository);

  Future<void> ejecutar(int id) async {
    await repository.eliminarBien(id);
  }
}
