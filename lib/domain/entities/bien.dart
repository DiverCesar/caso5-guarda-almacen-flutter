class Bien {
  static const String estadoDisponible = 'Disponible';
  static const String estadoEntregado = 'Entregado';
  static const String estadoEnMantenimiento = 'En mantenimiento';
  static const String estadoDadoDeBaja = 'Dado de baja';

  static const List<String> estadosValidos = [
    estadoDisponible,
    estadoEntregado,
    estadoEnMantenimiento,
    estadoDadoDeBaja,
  ];

  final int? id;
  final String codigoInstitucional; // único
  final String nombre;
  final String descripcion;
  final int cantidadTotal;
  final int cantidadDisponible;
  final String estado;

  Bien({
    this.id,
    required this.codigoInstitucional,
    required this.nombre,
    required this.descripcion,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.estado,
  });

  bool get isDisponible => estado == estadoDisponible && cantidadDisponible > 0;
  bool get isDadoDeBaja => estado == estadoDadoDeBaja;
  bool get isEnMantenimiento => estado == estadoEnMantenimiento;
  bool get isEntregado => estado == estadoEntregado;

  Bien copyWith({
    int? id,
    String? codigoInstitucional,
    String? nombre,
    String? descripcion,
    int? cantidadTotal,
    int? cantidadDisponible,
    String? estado,
  }) {
    return Bien(
      id: id ?? this.id,
      codigoInstitucional: codigoInstitucional ?? this.codigoInstitucional,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      estado: estado ?? this.estado,
    );
  }
}
