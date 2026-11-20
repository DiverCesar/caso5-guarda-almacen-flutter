class Entrega {
  static const String tipoTemporal = 'Temporal';
  static const String tipoDefinitiva = 'Definitiva';

  final int? id;
  final int bienId;
  final int responsableId;
  final String tipoEntrega; // Temporal o Definitiva
  final String fechaEntrega;
  final int cantidad;
  final String observacion;
  final String condicionEntrega;
  final bool devuelto;
  final String? fechaDevolucion;
  final String? condicionDevolucion;
  final bool presentaDano;

  Entrega({
    this.id,
    required this.bienId,
    required this.responsableId,
    required this.tipoEntrega,
    required this.fechaEntrega,
    required this.cantidad,
    required this.observacion,
    required this.condicionEntrega,
    this.devuelto = false,
    this.fechaDevolucion,
    this.condicionDevolucion,
    this.presentaDano = false,
  });

  bool get isDevuelto => devuelto;

  Entrega copyWith({
    int? id,
    int? bienId,
    int? responsableId,
    String? tipoEntrega,
    String? fechaEntrega,
    int? cantidad,
    String? observacion,
    String? condicionEntrega,
    bool? devuelto,
    String? fechaDevolucion,
    String? condicionDevolucion,
    bool? presentaDano,
  }) {
    return Entrega(
      id: id ?? this.id,
      bienId: bienId ?? this.bienId,
      responsableId: responsableId ?? this.responsableId,
      tipoEntrega: tipoEntrega ?? this.tipoEntrega,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      cantidad: cantidad ?? this.cantidad,
      observacion: observacion ?? this.observacion,
      condicionEntrega: condicionEntrega ?? this.condicionEntrega,
      devuelto: devuelto ?? this.devuelto,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      condicionDevolucion: condicionDevolucion ?? this.condicionDevolucion,
      presentaDano: presentaDano ?? this.presentaDano,
    );
  }
}
