import 'package:flutter/material.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/bien.dart';
import '../../domain/entities/entrega.dart';
import '../../domain/entities/responsable.dart';
import '../../domain/usecases/actualizar_bien_usecase.dart';
import '../../domain/usecases/cambiar_estado_bien_usecase.dart';
import '../../domain/usecases/crear_bien_usecase.dart';
import '../../domain/usecases/crear_responsable_usecase.dart';
import '../../domain/usecases/eliminar_bien_usecase.dart';
import '../../domain/usecases/obtener_bienes_usecase.dart';
import '../../domain/usecases/obtener_entregas_usecase.dart';
import '../../domain/usecases/obtener_responsables_usecase.dart';
import '../../domain/usecases/registrar_devolucion_usecase.dart';
import '../../domain/usecases/registrar_entrega_usecase.dart';

class AlmacenViewModel extends ChangeNotifier {
  final ObtenerBienesUseCase obtenerBienes;
  final CrearBienUseCase crearBien;
  final ActualizarBienUseCase actualizarBien;
  final CambiarEstadoBienUseCase cambiarEstadoBien;
  final EliminarBienUseCase eliminarBien;

  final ObtenerResponsablesUseCase obtenerResponsables;
  final CrearResponsableUseCase crearResponsable;

  final ObtenerEntregasUseCase obtenerEntregas;
  final RegistrarEntregaUseCase registrarEntregaUseCase;
  final RegistrarDevolucionUseCase registrarDevolucionUseCase;

  AlmacenViewModel({
    required this.obtenerBienes,
    required this.crearBien,
    required this.actualizarBien,
    required this.cambiarEstadoBien,
    required this.eliminarBien,
    required this.obtenerResponsables,
    required this.crearResponsable,
    required this.obtenerEntregas,
    required this.registrarEntregaUseCase,
    required this.registrarDevolucionUseCase,
  });

  // Estado
  List<Bien> bienes = [];
  List<Responsable> responsables = [];
  List<Entrega> entregas = [];

  bool cargando = false;
  String? error;
  String? mensajeExito;

  String filtroEstado = 'Todos';
  String busquedaQuery = '';
  Bien? bienSeleccionado;

  // --- Getters semánticos y de filtrado ---

  List<Bien> get bienesFiltrados {
    return bienes.where((b) {
      final cumpleFiltro = filtroEstado == 'Todos' || b.estado == filtroEstado;
      final query = busquedaQuery.trim().toLowerCase();
      final cumpleBusqueda = query.isEmpty ||
          b.codigoInstitucional.toLowerCase().contains(query) ||
          b.nombre.toLowerCase().contains(query) ||
          b.descripcion.toLowerCase().contains(query);
      return cumpleFiltro && cumpleBusqueda;
    }).toList();
  }

  List<Entrega> get entregasActivas => entregas.where((e) => !e.devuelto).toList();
  List<Entrega> get entregasDevueltas => entregas.where((e) => e.devuelto).toList();

  int get totalBienes => bienes.length;
  int get totalDisponibles => bienes.where((b) => b.isDisponible).length;
  int get totalEntregados => bienes.where((b) => b.isEntregado).length;
  int get totalEnMantenimiento => bienes.where((b) => b.isEnMantenimiento).length;
  int get totalDadosDeBaja => bienes.where((b) => b.isDadoDeBaja).length;
  int get totalEntregasActivas => entregasActivas.length;

  Responsable? getResponsableById(int id) {
    try {
      return responsables.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Bien? getBienById(int id) {
    try {
      return bienes.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Entrega> getHistorialBien(int bienId) {
    return entregas.where((e) => e.bienId == bienId).toList();
  }

  // --- Operaciones de datos ---

  Future<void> cargarTodo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        obtenerBienes.ejecutar(),
        obtenerResponsables.ejecutar(),
        obtenerEntregas.ejecutar(),
      ]);

      bienes = resultados[0] as List<Bien>;
      responsables = resultados[1] as List<Responsable>;
      entregas = resultados[2] as List<Entrega>;

      // Si había un bien seleccionado, refrescarlo
      if (bienSeleccionado != null) {
        bienSeleccionado = getBienById(bienSeleccionado!.id ?? -1);
      }
    } catch (e) {
      error = 'Error al cargar los datos: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> agregarBien(Bien bien) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await crearBien.ejecutar(bien);
      mensajeExito = 'Bien institucional registrado con éxito';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'No se pudo registrar el bien: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarBien(Bien bien) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await actualizarBien.ejecutar(bien);
      mensajeExito = 'Bien actualizado correctamente';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'No se pudo actualizar el bien: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstado(int bienId, String nuevoEstado) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await cambiarEstadoBien.ejecutar(bienId, nuevoEstado);
      mensajeExito = 'Estado cambiado a "$nuevoEstado"';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Error al cambiar estado: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> borrarBien(int id) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await eliminarBien.ejecutar(id);
      mensajeExito = 'Bien eliminado del inventario';
      await cargarTodo();
      return true;
    } catch (e) {
      error = 'Error al eliminar bien: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> agregarResponsable(Responsable responsable) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await crearResponsable.ejecutar(responsable);
      mensajeExito = 'Responsable registrado exitosamente';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Error al registrar responsable: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarEntrega(Entrega entrega) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await registrarEntregaUseCase.ejecutar(entrega);
      mensajeExito = 'Entrega registrada correctamente';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Error al registrar la entrega: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarDevolucion({
    required int entregaId,
    required String condicionDevolucion,
    required bool presentaDano,
    required String fechaDevolucion,
  }) async {
    cargando = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await registrarDevolucionUseCase.ejecutar(
        entregaId: entregaId,
        condicionDevolucion: condicionDevolucion,
        presentaDano: presentaDano,
        fechaDevolucion: fechaDevolucion,
      );
      mensajeExito = presentaDano
          ? 'Devolución registrada: Bien enviado automáticamente a mantenimiento por daño'
          : 'Devolución registrada exitosamente y stock reincorporado';
      await cargarTodo();
      return true;
    } on ValidationException catch (ve) {
      error = ve.message;
      cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Error al registrar devolución: $e';
      cargando = false;
      notifyListeners();
      return false;
    }
  }

  void setFiltroEstado(String estado) {
    filtroEstado = estado;
    notifyListeners();
  }

  void setBusquedaQuery(String query) {
    busquedaQuery = query;
    notifyListeners();
  }

  void seleccionarBien(Bien? bien) {
    bienSeleccionado = bien;
    notifyListeners();
  }

  void limpiarMensajes() {
    error = null;
    mensajeExito = null;
    notifyListeners();
  }
}
