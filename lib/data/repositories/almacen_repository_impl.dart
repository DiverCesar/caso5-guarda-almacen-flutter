import '../../domain/entities/bien.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/responsable.dart';
import '../../domain/repositories/almacen_repository.dart';
import '../datasources/almacen_api.dart';
import '../models/bien_model.dart';
import '../models/entrega_model.dart';
import '../models/responsable_model.dart';

class AlmacenRepositoryImpl implements AlmacenRepository {
  final AlmacenApi api;

  AlmacenRepositoryImpl(this.api);

  @override
  Future<List<Responsable>> obtenerResponsables() async {
    return await api.obtenerResponsables();
  }

  @override
  Future<Responsable> crearResponsable(Responsable responsable) async {
    final model = ResponsableModel.fromEntity(responsable);
    return await api.crearResponsable(model);
  }

  @override
  Future<List<Bien>> obtenerBienes() async {
    return await api.obtenerBienes();
  }

  @override
  Future<Bien> crearBien(Bien bien) async {
    final model = BienModel.fromEntity(bien);
    return await api.crearBien(model);
  }

  @override
  Future<Bien> actualizarBien(Bien bien) async {
    final model = BienModel.fromEntity(bien);
    return await api.actualizarBien(model);
  }

  @override
  Future<void> eliminarBien(int id) async {
    await api.eliminarBien(id);
  }

  @override
  Future<List<Entrega>> obtenerEntregas() async {
    return await api.obtenerEntregas();
  }

  @override
  Future<Entrega> registrarEntrega(Entrega entrega) async {
    final model = EntregaModel.fromEntity(entrega);
    return await api.registrarEntrega(model);
  }

  @override
  Future<Entrega> registrarDevolucion({
    required int entregaId,
    required String condicionDevolucion,
    required bool presentaDano,
    required String fechaDevolucion,
  }) async {
    return await api.registrarDevolucion(
      entregaId: entregaId,
      condicionDevolucion: condicionDevolucion,
      presentaDano: presentaDano,
      fechaDevolucion: fechaDevolucion,
    );
  }
}
