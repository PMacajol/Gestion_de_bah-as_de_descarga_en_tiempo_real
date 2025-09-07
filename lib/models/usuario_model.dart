enum TipoUsuario { administrador, usuario }

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
}
