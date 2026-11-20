import '../../domain/entities/responsable.dart';

class ResponsableModel extends Responsable {
  ResponsableModel({
    super.id,
    required super.nombre,
    required super.cargo,
    required super.area,
    required super.contacto,
  });

  factory ResponsableModel.fromJson(Map<String, dynamic> json) {
    return ResponsableModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      nombre: json['nombre'] ?? '',
      cargo: json['cargo'] ?? 'docente',
      area: json['area'] ?? '',
      contacto: json['contacto'] ?? json['correo'] ?? json['telefono'] ?? '',
    );
  }

  factory ResponsableModel.fromEntity(Responsable entity) {
    return ResponsableModel(
      id: entity.id,
      nombre: entity.nombre,
      cargo: entity.cargo,
      area: entity.area,
      contacto: entity.contacto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'cargo': cargo,
      'area': area,
      'contacto': contacto,
    };
  }
}
