import '../entities/bien.dart';
import '../entities/entrega.dart';
import '../entities/responsable.dart';

abstract class AlmacenRepository {
  // Responsables
  Future<List<Responsable>> obtenerResponsables();
  Future<Responsable> crearResponsable(Responsable responsable);

  // Bienes
  Future<List<Bien>> obtenerBienes();
  Future<Bien> crearBien(Bien bien);
  Future<Bien> actualizarBien(Bien bien);
  Future<void> eliminarBien(int id);

  // Entregas
  Future<List<Entrega>> obtenerEntregas();
  Future<Entrega> registrarEntrega(Entrega entrega);
  Future<Entrega> registrarDevolucion({
    required int entregaId,
    required String condicionDevolucion,
    required bool presentaDano,
    required String fechaDevolucion,
  });
}
