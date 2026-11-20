import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/bien_model.dart';
import '../models/entrega_model.dart';
import '../models/responsable_model.dart';

class AlmacenApi {
  // URLs para Desktop / Web / Emulador Android
  final String baseUrl;
  final http.Client client;
  final bool usarSoloMemoria;

  AlmacenApi({
    String? customBaseUrl,
    http.Client? customClient,
    this.usarSoloMemoria = false,
  })  : baseUrl = customBaseUrl ?? _determinarBaseUrl(),
        client = customClient ?? http.Client();

  static String _determinarBaseUrl() {
    // Si corre en Android emulador, suele usarse 10.0.2.2; en Linux/Desktop/Web se usa localhost
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  // --- Memoria Fallback Transparente (Seed Data) ---
  final List<ResponsableModel> _memoriaResponsables = [
    ResponsableModel(
      id: 1,
      nombre: 'Ing. Carlos Mendoza',
      cargo: 'docente',
      area: 'Sistemas e Informática',
      contacto: 'carlos.mendoza@universidad.edu.ec',
    ),
    ResponsableModel(
      id: 2,
      nombre: 'Laboratorio de Redes y Telecomunicaciones',
      cargo: 'laboratorio',
      area: 'Telecomunicaciones',
      contacto: 'lab.redes@universidad.edu.ec',
    ),
    ResponsableModel(
      id: 3,
      nombre: 'Lic. Ana Belén Tapia',
      cargo: 'oficina',
      area: 'Dirección de Talento Humano',
      contacto: '0998765432',
    ),
    ResponsableModel(
      id: 4,
      nombre: 'Dr. Jorge Morales',
      cargo: 'responsable de proyecto',
      area: 'Investigación Robótica y AI',
      contacto: 'jorge.morales@universidad.edu.ec',
    ),
  ];

  final List<BienModel> _memoriaBienes = [
    BienModel(
      id: 1,
      codigoInstitucional: 'EPN-PRJ-001',
      nombre: 'Proyector Epson PowerLite E20',
      descripcion: 'Proyector 3LCD 3400 lúmenes para aulas magna',
      cantidadTotal: 3,
      cantidadDisponible: 2,
      estado: 'Disponible',
    ),
    BienModel(
      id: 2,
      codigoInstitucional: 'LAB-OSC-014',
      nombre: 'Osciloscopio Digital Tektronix TBS1052B',
      descripcion: 'Osciloscopio 50MHz 2 canales para lab de electrónica',
      cantidadTotal: 4,
      cantidadDisponible: 0,
      estado: 'Entregado',
    ),
    BienModel(
      id: 3,
      codigoInstitucional: 'TI-LAP-089',
      nombre: 'Laptop Dell Latitude 5420',
      descripcion: 'Laptop Intel Core i7 16GB RAM para proyectos de investigación',
      cantidadTotal: 5,
      cantidadDisponible: 0,
      estado: 'En mantenimiento',
    ),
    BienModel(
      id: 4,
      codigoInstitucional: 'ROB-ARD-022',
      nombre: 'Kit Arduino Mega 2560 Pro',
      descripcion: 'Kit de robótica educativa con sensores y actuadores',
      cantidadTotal: 10,
      cantidadDisponible: 8,
      estado: 'Disponible',
    ),
    BienModel(
      id: 5,
      codigoInstitucional: 'OFI-SIL-005',
      nombre: 'Silla Ergonómica Herman Miller',
      descripcion: 'Silla de oficina con base fracturada reportada para reciclaje',
      cantidadTotal: 2,
      cantidadDisponible: 0,
      estado: 'Dado de baja',
    ),
  ];

  final List<EntregaModel> _memoriaEntregas = [
    EntregaModel(
      id: 1,
      bienId: 2,
      responsableId: 1,
      tipoEntrega: 'Temporal',
      fechaEntrega: '2026-11-15',
      cantidad: 4,
      observacion: 'Uso en práctica de laboratorio de circuitos digitales',
      condicionEntrega: 'Óptimo',
      devuelto: false,
      fechaDevolucion: null,
      condicionDevolucion: null,
      presentaDano: false,
    ),
    EntregaModel(
      id: 2,
      bienId: 3,
      responsableId: 4,
      tipoEntrega: 'Temporal',
      fechaEntrega: '2026-11-01',
      cantidad: 5,
      observacion: 'Desarrollo de simulaciones neuronales',
      condicionEntrega: 'Óptimo',
      devuelto: true,
      fechaDevolucion: '2026-11-18',
      condicionDevolucion: 'Falla en teclado y pantalla parpadeante',
      presentaDano: true,
    ),
  ];

  static const Duration _timeout = Duration(milliseconds: 2500);

  // ==================== RESPONSABLES ====================

  Future<List<ResponsableModel>> obtenerResponsables() async {
    if (usarSoloMemoria) return List<ResponsableModel>.from(_memoriaResponsables);
    try {
      final respuesta = await client.get(Uri.parse('$baseUrl/responsables')).timeout(_timeout);
      if (respuesta.statusCode == 200) {
        final List<dynamic> datos = jsonDecode(respuesta.body);
        final lista = datos.map((item) => ResponsableModel.fromJson(item)).toList();
        _memoriaResponsables.clear();
        _memoriaResponsables.addAll(lista);
        return lista;
      }
    } catch (e) {
      debugPrint('[AlmacenApi] Fallback en memoria para obtenerResponsables: $e');
    }
    return List<ResponsableModel>.from(_memoriaResponsables);
  }

  Future<ResponsableModel> crearResponsable(ResponsableModel responsable) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client
            .post(
              Uri.parse('$baseUrl/responsables'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(responsable.toJson()),
            )
            .timeout(_timeout);

        if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
          final creado = ResponsableModel.fromJson(jsonDecode(respuesta.body));
          _memoriaResponsables.removeWhere((r) => r.id == creado.id);
          _memoriaResponsables.add(creado);
          return creado;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para crearResponsable: $e');
      }
    }

    final newId = _memoriaResponsables.isNotEmpty
        ? (_memoriaResponsables.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1)
        : 1;
    final nuevo = ResponsableModel(
      id: newId,
      nombre: responsable.nombre,
      cargo: responsable.cargo,
      area: responsable.area,
      contacto: responsable.contacto,
    );
    _memoriaResponsables.add(nuevo);
    return nuevo;
  }

  // ==================== BIENES ====================

  Future<List<BienModel>> obtenerBienes() async {
    if (usarSoloMemoria) return List<BienModel>.from(_memoriaBienes);
    try {
      final respuesta = await client.get(Uri.parse('$baseUrl/bienes')).timeout(_timeout);
      if (respuesta.statusCode == 200) {
        final List<dynamic> datos = jsonDecode(respuesta.body);
        final lista = datos.map((item) => BienModel.fromJson(item)).toList();
        _memoriaBienes.clear();
        _memoriaBienes.addAll(lista);
        return lista;
      }
    } catch (e) {
      debugPrint('[AlmacenApi] Fallback en memoria para obtenerBienes: $e');
    }
    return List<BienModel>.from(_memoriaBienes);
  }

  Future<BienModel> crearBien(BienModel bien) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client
            .post(
              Uri.parse('$baseUrl/bienes'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(bien.toJson()),
            )
            .timeout(_timeout);

        if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
          final creado = BienModel.fromJson(jsonDecode(respuesta.body));
          _memoriaBienes.removeWhere((b) => b.id == creado.id);
          _memoriaBienes.add(creado);
          return creado;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para crearBien: $e');
      }
    }

    final newId = _memoriaBienes.isNotEmpty
        ? (_memoriaBienes.map((b) => b.id ?? 0).reduce((a, b) => a > b ? a : b) + 1)
        : 1;
    final nuevo = BienModel(
      id: newId,
      codigoInstitucional: bien.codigoInstitucional,
      nombre: bien.nombre,
      descripcion: bien.descripcion,
      cantidadTotal: bien.cantidadTotal,
      cantidadDisponible: bien.cantidadDisponible,
      estado: bien.estado,
    );
    _memoriaBienes.add(nuevo);
    return nuevo;
  }

  Future<BienModel> actualizarBien(BienModel bien) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client
            .put(
              Uri.parse('$baseUrl/bienes/${bien.id}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(bien.toJson()),
            )
            .timeout(_timeout);

        if (respuesta.statusCode == 200) {
          final actualizado = BienModel.fromJson(jsonDecode(respuesta.body));
          final index = _memoriaBienes.indexWhere((b) => b.id == actualizado.id);
          if (index != -1) {
            _memoriaBienes[index] = actualizado;
          } else {
            _memoriaBienes.add(actualizado);
          }
          return actualizado;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para actualizarBien: $e');
      }
    }

    final index = _memoriaBienes.indexWhere((b) => b.id == bien.id);
    if (index != -1) {
      _memoriaBienes[index] = bien;
      return bien;
    } else {
      _memoriaBienes.add(bien);
      return bien;
    }
  }

  Future<void> eliminarBien(int id) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client.delete(Uri.parse('$baseUrl/bienes/$id')).timeout(_timeout);
        if (respuesta.statusCode == 200) {
          _memoriaBienes.removeWhere((b) => b.id == id);
          return;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para eliminarBien: $e');
      }
    }

    _memoriaBienes.removeWhere((b) => b.id == id);
  }

  // ==================== ENTREGAS ====================

  Future<List<EntregaModel>> obtenerEntregas() async {
    if (usarSoloMemoria) return List<EntregaModel>.from(_memoriaEntregas);
    try {
      final respuesta = await client.get(Uri.parse('$baseUrl/entregas')).timeout(_timeout);
      if (respuesta.statusCode == 200) {
        final List<dynamic> datos = jsonDecode(respuesta.body);
        final lista = datos.map((item) => EntregaModel.fromJson(item)).toList();
        _memoriaEntregas.clear();
        _memoriaEntregas.addAll(lista);
        return lista;
      }
    } catch (e) {
      debugPrint('[AlmacenApi] Fallback en memoria para obtenerEntregas: $e');
    }
    return List<EntregaModel>.from(_memoriaEntregas);
  }

  Future<EntregaModel> registrarEntrega(EntregaModel entrega) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client
            .post(
              Uri.parse('$baseUrl/entregas'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(entrega.toJson()),
            )
            .timeout(_timeout);

        if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
          final creada = EntregaModel.fromJson(jsonDecode(respuesta.body));
          _memoriaEntregas.removeWhere((e) => e.id == creada.id);
          _memoriaEntregas.add(creada);
          return creada;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para registrarEntrega: $e');
      }
    }

    final newId = _memoriaEntregas.isNotEmpty
        ? (_memoriaEntregas.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1)
        : 1;
    final nueva = EntregaModel(
      id: newId,
      bienId: entrega.bienId,
      responsableId: entrega.responsableId,
      tipoEntrega: entrega.tipoEntrega,
      fechaEntrega: entrega.fechaEntrega,
      cantidad: entrega.cantidad,
      observacion: entrega.observacion,
      condicionEntrega: entrega.condicionEntrega,
      devuelto: false,
      fechaDevolucion: null,
      condicionDevolucion: null,
      presentaDano: false,
    );
    _memoriaEntregas.add(nueva);
    return nueva;
  }

  Future<EntregaModel> registrarDevolucion({
    required int entregaId,
    required String condicionDevolucion,
    required bool presentaDano,
    required String fechaDevolucion,
  }) async {
    if (!usarSoloMemoria) {
      try {
        final respuesta = await client
            .put(
              Uri.parse('$baseUrl/entregas/$entregaId/devolucion'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'condicionDevolucion': condicionDevolucion,
                'presentaDano': presentaDano,
                'fechaDevolucion': fechaDevolucion,
              }),
            )
            .timeout(_timeout);

        if (respuesta.statusCode == 200) {
          final devuelta = EntregaModel.fromJson(jsonDecode(respuesta.body));
          final index = _memoriaEntregas.indexWhere((e) => e.id == devuelta.id);
          if (index != -1) {
            _memoriaEntregas[index] = devuelta;
          } else {
            _memoriaEntregas.add(devuelta);
          }
          return devuelta;
        }
      } catch (e) {
        debugPrint('[AlmacenApi] Fallback en memoria para registrarDevolucion: $e');
      }
    }

    final index = _memoriaEntregas.indexWhere((e) => e.id == entregaId);
    if (index != -1) {
      final actual = _memoriaEntregas[index];
      final actualizada = actual.copyWith(
        devuelto: true,
        condicionDevolucion: condicionDevolucion,
        presentaDano: presentaDano,
        fechaDevolucion: fechaDevolucion,
      );
      _memoriaEntregas[index] = EntregaModel.fromEntity(actualizada);
      return _memoriaEntregas[index];
    } else {
      throw Exception('Entrega no encontrada en memoria.');
    }
  }
}
