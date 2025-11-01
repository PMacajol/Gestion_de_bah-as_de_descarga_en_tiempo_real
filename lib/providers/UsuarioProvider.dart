import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bahias_descarga_system/models/usuario_model.dart';

abstract class TokenReceiver {
  void setToken(String token);
}

class UsuarioProvider with ChangeNotifier implements TokenReceiver {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  String? _token;
  final String _baseUrl =
      'https://bahiarealtime-czbxgfg4c4g3f0e6.canadacentral-01.azurewebsites.net/api';

  List<Usuario> get usuarios =>
      _usuariosFiltrados.isEmpty && _filtroTipo == null && _filtroActivo == null
          ? _usuarios
          : _usuariosFiltrados;

  String? _filtroTipo;
  bool? _filtroActivo;

  @override
  void setToken(String token) {
    _token = token;
    print(
        '🔑 Token establecido en UsuarioProvider: ${token.substring(0, 20)}...');
  }

  // === CARGAR USUARIOS ===
  Future<void> cargarUsuarios() async {
    try {
      print('🔄 Cargando usuarios...');
      final response = await http.get(
        Uri.parse('$_baseUrl/usuarios/'),
        headers: _headers(),
      );

      print('📥 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _usuarios = data.map((json) => Usuario.fromJson(json)).toList();
        _usuariosFiltrados = _usuarios;
        notifyListeners();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en cargarUsuarios: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // === OBTENER USUARIO ESPECÍFICO ===
  Future<Usuario> obtenerUsuario(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usuarios/$id'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // === CREAR USUARIO ===
  Future<void> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String tipoUsuario,
  }) async {
    try {
      final body = {
        "nombre": nombre,
        "email": email,
        "password": password,
        "tipo_usuario": tipoUsuario,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/registro'),
        headers: _headers(),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Usuario creado correctamente');
        await cargarUsuarios();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      print('❌ Error en crearUsuario: $e');
      throw Exception('Error: $e');
    }
  }

  // === ACTUALIZAR USUARIO ===
  Future<void> actualizarUsuario({
    required String id,
    required String nombre,
    required String email,
    required String tipoUsuario,
    String? password,
  }) async {
    try {
      final body = {
        "nombre": nombre,
        "email": email,
        "tipo_usuario": tipoUsuario,
        if (password != null && password.isNotEmpty) "password": password,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/usuarios/$id'),
        headers: _headers(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Usuario actualizado correctamente');
        await cargarUsuarios();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      print('❌ Error en actualizarUsuario: $e');
      throw Exception('Error: $e');
    }
  }

  // === ACTIVAR USUARIO ===
  Future<void> activarUsuario(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios/$id/activar'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Usuario activado correctamente');
        await cargarUsuarios();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al activar usuario');
      }
    } catch (e) {
      print('❌ Error en activarUsuario: $e');
      throw Exception('Error: $e');
    }
  }

  // === DESACTIVAR USUARIO ===
  Future<void> desactivarUsuario(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/usuarios/$id'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Usuario desactivado correctamente');
        await cargarUsuarios();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al desactivar usuario');
      }
    } catch (e) {
      print('❌ Error en desactivarUsuario: $e');
      throw Exception('Error: $e');
    }
  }

  // === FILTRAR USUARIOS ===
  void filtrarUsuarios({String? tipo, bool? activo}) {
    _filtroTipo = tipo;
    _filtroActivo = activo;

    _usuariosFiltrados = _usuarios.where((usuario) {
      bool cumpleTipo =
          tipo == null || usuario.tipo.toString().split('.').last == tipo;
      bool cumpleActivo = activo == null || usuario.activo == activo;
      return cumpleTipo && cumpleActivo;
    }).toList();

    notifyListeners();
  }

  // === LIMPIAR FILTROS ===
  void limpiarFiltros() {
    _filtroTipo = null;
    _filtroActivo = null;
    _usuariosFiltrados = _usuarios;
    notifyListeners();
  }

  // === HEADERS ===
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
