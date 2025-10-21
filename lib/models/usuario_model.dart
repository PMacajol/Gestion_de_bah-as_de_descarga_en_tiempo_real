enum TipoUsuario {
  administrador,
  operador,
  planificador,
  supervisor,
  administradorTI
}

class Usuario {
  final String id;
  final String email;
  final String nombre;
  final TipoUsuario tipo;
  final bool activo;
  final DateTime fechaRegistro;
  final DateTime fechaUltimaModificacion;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.tipo,
    required this.activo,
    required this.fechaRegistro,
    required this.fechaUltimaModificacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      tipo: _parseTipoUsuario(json['tipo_usuario']),
      activo: json['activo'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      fechaUltimaModificacion:
          DateTime.parse(json['fecha_ultima_modificacion']),
    );
  }

  static TipoUsuario _parseTipoUsuario(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'administrador':
        return TipoUsuario.administrador;
      case 'operador':
        return TipoUsuario.operador;
      case 'planificador':
        return TipoUsuario.planificador;
      case 'supervisor':
        return TipoUsuario.supervisor;
      case 'administrador_ti':
        return TipoUsuario.administradorTI;
      default:
        return TipoUsuario.operador;
    }
  }

  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esOperador => tipo == TipoUsuario.operador;
  bool get esPlanificador => tipo == TipoUsuario.planificador;
  bool get esSupervisor => tipo == TipoUsuario.supervisor;
  bool get esAdministradorTI => tipo == TipoUsuario.administradorTI;
}
