import 'package:flutter/foundation.dart';
import 'package:bahias_descarga_system/models/usuario_model.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;
  bool _autenticado = false;

  Usuario? get usuario => _usuario;
  bool get autenticado => _autenticado;

  // Datos simulados de usuarios
  final List<Usuario> _usuariosSimulados = [
    Usuario(
      id: '1',
      email: 'admin@empresa.com',
      nombre: 'Administrador Sistema',
      tipo: TipoUsuario.administrador,
      fechaRegistro: DateTime.now(),
    ),
    Usuario(
      id: '2',
      email: 'operador@empresa.com',
      nombre: 'Juan Pérez Operador',
      tipo: TipoUsuario.operador,
      fechaRegistro: DateTime.now(),
    ),
    Usuario(
      id: '3',
      email: 'planificador@empresa.com',
      nombre: 'María García Planificador',
      tipo: TipoUsuario.planificador,
      fechaRegistro: DateTime.now(),
    ),
    Usuario(
      id: '4',
      email: 'supervisor@empresa.com',
      nombre: 'Carlos López Supervisor',
      tipo: TipoUsuario.supervisor,
      fechaRegistro: DateTime.now(),
    ),
    Usuario(
      id: '5',
      email: 'ti@empresa.com',
      nombre: 'Ana Rodríguez TI',
      tipo: TipoUsuario.administradorTI,
      fechaRegistro: DateTime.now(),
    ),
  ];

  Future<bool> login(String email, String password) async {
    // Simular tiempo de espera de red
    await Future.delayed(const Duration(seconds: 1));

    // Buscar usuario en la lista simulada
    final usuario = _usuariosSimulados.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Usuario no encontrado'),
    );

    // Simular verificación de contraseña (en un caso real, esto se haría con hash)
    if (password != 'password123') {
      throw Exception('Contraseña incorrecta');
    }

    _usuario = usuario;
    _autenticado = true;
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password, String nombre) async {
    await Future.delayed(const Duration(seconds: 1));

    // Verificar si el usuario ya existe
    if (_usuariosSimulados.any((u) => u.email == email)) {
      throw Exception('El usuario ya existe');
    }

    // Crear nuevo usuario
    final nuevoUsuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      nombre: nombre,
      tipo: TipoUsuario.operador, // Por defecto es operador
      fechaRegistro: DateTime.now(),
    );

    _usuariosSimulados.add(nuevoUsuario);
    _usuario = nuevoUsuario;
    _autenticado = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _usuario = null;
    _autenticado = false;
    notifyListeners();
  }
}
