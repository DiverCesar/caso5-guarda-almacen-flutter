class Responsable {
  final int? id;
  final String nombre;
  final String cargo; // docente, laboratorio, oficina, responsable de proyecto
  final String area;
  final String contacto; // correo o telefono

  Responsable({
    this.id,
    required this.nombre,
    required this.cargo,
    required this.area,
    required this.contacto,
  });

  Responsable copyWith({
    int? id,
    String? nombre,
    String? cargo,
    String? area,
    String? contacto,
  }) {
    return Responsable(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      area: area ?? this.area,
      contacto: contacto ?? this.contacto,
    );
  }
}
