class DiaFestivo {
  final int? id;
  final DateTime fecha;
  final String nombreLocal;
  final String nombre;
  final String codigoPais;
  final int anio;

  const DiaFestivo({
    this.id,
    required this.fecha,
    required this.nombreLocal,
    required this.nombre,
    required this.codigoPais,
    required this.anio,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha': fecha.millisecondsSinceEpoch,
        'nombre_local': nombreLocal,
        'nombre': nombre,
        'codigo_pais': codigoPais,
        'anio': anio,
      };

  factory DiaFestivo.fromMap(Map<String, Object?> m) => DiaFestivo(
        id: m['id'] as int?,
        fecha: DateTime.fromMillisecondsSinceEpoch(m['fecha'] as int),
        nombreLocal: m['nombre_local'] as String,
        nombre: m['nombre'] as String,
        codigoPais: m['codigo_pais'] as String,
        anio: m['anio'] as int,
      );
}
