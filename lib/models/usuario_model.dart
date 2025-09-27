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
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.tipo,
    required this.fechaRegistro,
  });

  bool get esAdministrador => tipo == TipoUsuario.administrador;
  bool get esOperador => tipo == TipoUsuario.operador;
  bool get esPlanificador => tipo == TipoUsuario.planificador;
  bool get esSupervisor => tipo == TipoUsuario.supervisor;
  bool get esAdministradorTI => tipo == TipoUsuario.administradorTI;
}
