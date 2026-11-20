import '../../domain/entities/entrega.dart';

class EntregaModel extends Entrega {
  EntregaModel({
    super.id,
    required super.bienId,
    required super.responsableId,
    required super.tipoEntrega,
    required super.fechaEntrega,
    required super.cantidad,
    required super.observacion,
    required super.condicionEntrega,
    super.devuelto = false,
    super.fechaDevolucion,
    super.condicionDevolucion,
    super.presentaDano = false,
  });

  factory EntregaModel.fromJson(Map<String, dynamic> json) {
    return EntregaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      bienId: (json['bienId'] is num)
          ? (json['bienId'] as num).toInt()
          : int.tryParse(json['bienId']?.toString() ?? '') ?? 0,
      responsableId: (json['responsableId'] is num)
          ? (json['responsableId'] as num).toInt()
          : int.tryParse(json['responsableId']?.toString() ?? '') ?? 0,
      tipoEntrega: json['tipoEntrega'] ?? Entrega.tipoTemporal,
      fechaEntrega: json['fechaEntrega'] ?? '',
      cantidad: (json['cantidad'] is num)
          ? (json['cantidad'] as num).toInt()
          : int.tryParse(json['cantidad']?.toString() ?? '') ?? 1,
      observacion: json['observacion'] ?? '',
      condicionEntrega: json['condicionEntrega'] ?? 'Óptimo',
      devuelto: json['devuelto'] == true || json['devuelto'] == 'true',
      fechaDevolucion: json['fechaDevolucion'],
      condicionDevolucion: json['condicionDevolucion'],
      presentaDano: json['presentaDano'] == true || json['presentaDano'] == 'true',
    );
  }

  factory EntregaModel.fromEntity(Entrega entity) {
    return EntregaModel(
      id: entity.id,
      bienId: entity.bienId,
      responsableId: entity.responsableId,
      tipoEntrega: entity.tipoEntrega,
      fechaEntrega: entity.fechaEntrega,
      cantidad: entity.cantidad,
      observacion: entity.observacion,
      condicionEntrega: entity.condicionEntrega,
      devuelto: entity.devuelto,
      fechaDevolucion: entity.fechaDevolucion,
      condicionDevolucion: entity.condicionDevolucion,
      presentaDano: entity.presentaDano,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bienId': bienId,
      'responsableId': responsableId,
      'tipoEntrega': tipoEntrega,
      'fechaEntrega': fechaEntrega,
      'cantidad': cantidad,
      'observacion': observacion,
      'condicionEntrega': condicionEntrega,
      'devuelto': devuelto,
      'fechaDevolucion': fechaDevolucion,
      'condicionDevolucion': condicionDevolucion,
      'presentaDano': presentaDano,
    };
  }
}
