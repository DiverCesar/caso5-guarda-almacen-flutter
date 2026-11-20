import '../../domain/entities/bien.dart';

class BienModel extends Bien {
  BienModel({
    super.id,
    required super.codigoInstitucional,
    required super.nombre,
    required super.descripcion,
    required super.cantidadTotal,
    required super.cantidadDisponible,
    required super.estado,
  });

  factory BienModel.fromJson(Map<String, dynamic> json) {
    final cantTotal = (json['cantidadTotal'] is num)
        ? (json['cantidadTotal'] as num).toInt()
        : int.tryParse(json['cantidadTotal']?.toString() ?? '') ?? 1;

    final cantDisp = (json['cantidadDisponible'] is num)
        ? (json['cantidadDisponible'] as num).toInt()
        : int.tryParse(json['cantidadDisponible']?.toString() ?? '') ?? cantTotal;

    return BienModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      codigoInstitucional: json['codigoInstitucional'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      cantidadTotal: cantTotal,
      cantidadDisponible: cantDisp,
      estado: json['estado'] ?? Bien.estadoDisponible,
    );
  }

  factory BienModel.fromEntity(Bien entity) {
    return BienModel(
      id: entity.id,
      codigoInstitucional: entity.codigoInstitucional,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      cantidadTotal: entity.cantidadTotal,
      cantidadDisponible: entity.cantidadDisponible,
      estado: entity.estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'codigoInstitucional': codigoInstitucional,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidadTotal': cantidadTotal,
      'cantidadDisponible': cantidadDisponible,
      'estado': estado,
    };
  }
}
