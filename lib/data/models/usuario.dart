class Usuario {
  final int? id;
  final String nombre;
  final String correo;
  final String passwordHash;
  final String sal;

  const Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.passwordHash,
    required this.sal,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'password_hash': passwordHash,
        'sal': sal,
      };

  factory Usuario.fromMap(Map<String, Object?> m) => Usuario(
        id: m['id'] as int?,
        nombre: m['nombre'] as String,
        correo: m['correo'] as String,
        passwordHash: m['password_hash'] as String,
        sal: m['sal'] as String,
      );

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final a = partes.first.isNotEmpty ? partes.first[0] : '';
    final b = partes.length > 1 && partes[1].isNotEmpty ? partes[1][0] : '';
    return (a + b).toUpperCase();
  }
}
