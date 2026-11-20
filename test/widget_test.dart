import 'package:flutter_test/flutter_test.dart';
import 'package:guarda_almacen_app/data/datasources/almacen_api.dart';
import 'package:guarda_almacen_app/data/repositories/almacen_repository_impl.dart';
import 'package:guarda_almacen_app/domain/entities/bien.dart';
import 'package:guarda_almacen_app/domain/entities/entrega.dart';
import 'package:guarda_almacen_app/domain/usecases/crear_bien_usecase.dart';
import 'package:guarda_almacen_app/domain/usecases/obtener_bienes_usecase.dart';
import 'package:guarda_almacen_app/domain/usecases/registrar_devolucion_usecase.dart';
import 'package:guarda_almacen_app/domain/usecases/registrar_entrega_usecase.dart';

void main() {
  late AlmacenApi api;
  late AlmacenRepositoryImpl repository;

  setUp(() {
    api = AlmacenApi(usarSoloMemoria: true);
    repository = AlmacenRepositoryImpl(api);
  });

  test('Validación Caso 5: Regla 1 - Código institucional único', () async {
    final crearBien = CrearBienUseCase(repository);

    // Intentar registrar un bien con código ya existente en la semilla (EPN-PRJ-001)
    expect(
      () => crearBien.ejecutar(
        Bien(
          codigoInstitucional: 'EPN-PRJ-001',
          nombre: 'Proyector duplicado',
          descripcion: 'Test',
          cantidadTotal: 1,
          cantidadDisponible: 1,
          estado: Bien.estadoDisponible,
        ),
      ),
      throwsException,
    );
  });

  test('Validación Caso 5: Regla 2 y 6 - Control de disponibilidad y stock al entregar', () async {
    final registrarEntrega = RegistrarEntregaUseCase(repository);

    // Intentar entregar más stock del disponible
    expect(
      () => registrarEntrega.ejecutar(
        Entrega(
          bienId: 1, // EPN-PRJ-001 tiene 2 disponibles
          responsableId: 1,
          tipoEntrega: Entrega.tipoTemporal,
          fechaEntrega: '2026-11-20',
          cantidad: 99, // Excede stock
          observacion: 'Prueba exceso stock',
          condicionEntrega: 'Óptimo',
        ),
      ),
      throwsException,
    );
  });

  test('Validación Caso 5: Regla 10 - Bien con daño pasa automáticamente a En mantenimiento', () async {
    final registrarDevolucion = RegistrarDevolucionUseCase(repository);
    final obtenerBienes = ObtenerBienesUseCase(repository);

    // Entrega activa 1: Osciloscopio Digital (bienId: 2)
    await registrarDevolucion.ejecutar(
      entregaId: 1,
      condicionDevolucion: 'Pantalla con fisura y perilla averiada',
      presentaDano: true,
      fechaDevolucion: '2026-11-20',
    );

    final bienes = await obtenerBienes.ejecutar();
    final bienAfectado = bienes.firstWhere((b) => b.id == 2);

    expect(bienAfectado.estado, Bien.estadoEnMantenimiento);
  });
}
