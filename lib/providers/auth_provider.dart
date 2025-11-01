import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bahias_descarga_system/models/usuario_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;
  bool _autenticado = false;
  String? _token;

  Usuario? get usuario => _usuario;
  bool get autenticado => _autenticado;
  String? get token => _token;

  // URL base - IMPORTANTE: Cambia según tu entorno
  static const String _baseUrl =
      'https://bahiarealtime-czbxgfg4c4g3f0e6.canadacentral-01.azurewebsites.net';
  // Método para verificar conexión con el backend
  Future<bool> verificarConexion() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Verificar conexión primero
      final conectado = await verificarConexion();
      if (!conectado) {
        throw Exception(
            'No se puede conectar al servidor. Verifica que el backend esté ejecutándose en $_baseUrl');
      }

      final url = Uri.parse('$_baseUrl/api/auth/login');
      print('🔗 Intentando login en: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extraer el token y los datos del usuario
        _token = data['access_token'];
        final usuarioJson = data['usuario'];

        // Convertir el JSON a un objeto Usuario
        _usuario = Usuario.fromJson(usuarioJson);
        _autenticado = true;

        // Guardar el token y datos del usuario localmente
        await _saveAuthData(_token!, usuarioJson);

        print('🔑 Token obtenido: ${_token!.substring(0, 20)}...');
        print('👤 Usuario: ${_usuario!.nombre} (${_usuario!.email})');

        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error en el login');
      }
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> register(String email, String password, String nombre) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/registro');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'nombre': nombre,
          'tipo_usuario': 'operador', // Por defecto
        }),
      );

      if (response.statusCode == 200) {
        // El registro fue exitoso, ahora hacemos login automáticamente
        return await login(email, password);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error en el registro');
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> logout() async {
    // Eliminar datos locales
    await _clearAuthData();

    _usuario = null;
    _autenticado = false;
    _token = null;

    print('🚪 Sesión cerrada');
    notifyListeners();
  }

  // Métodos para persistencia de datos
  Future<void> _saveAuthData(
      String token, Map<String, dynamic> usuarioJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('usuario', json.encode(usuarioJson));
    print('💾 Datos de sesión guardados localmente');
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');
    print('🧹 Datos de sesión eliminados');
  }

  // Método para cargar la sesión al iniciar la app
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioString = prefs.getString('usuario');

    if (token != null && usuarioString != null) {
      try {
        final usuarioJson = json.decode(usuarioString);
        _token = token;
        _usuario = Usuario.fromJson(usuarioJson);
        _autenticado = true;

        print('🔄 Auto-login exitoso');
        print('🔑 Token recuperado: ${_token!.substring(0, 20)}...');
        print('👤 Usuario: ${_usuario!.nombre}');

        notifyListeners();
        return true;
      } catch (e) {
        print('❌ Error en auto-login: $e');
        await _clearAuthData();
        return false;
      }
    }
    print('⚠️ No hay datos de sesión guardados');
    return false;
  }

  // Método para obtener el usuario actual desde el backend
  Future<void> getCurrentUser() async {
    if (_token == null) {
      print('❌ No hay token para obtener usuario actual');
      return;
    }

    try {
      final url = Uri.parse('$_baseUrl/api/auth/me');
      print('🔗 Obteniendo usuario actual: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final usuarioJson = json.decode(response.body);
        _usuario = Usuario.fromJson(usuarioJson);

        // Actualizar datos locales
        await _saveAuthData(_token!, usuarioJson);
        print('✅ Usuario actual obtenido: ${_usuario!.nombre}');

        notifyListeners();
      } else {
        print('❌ Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener usuario actual: $e');
    }
  }

  // === NUEVOS MÉTODOS AGREGADOS ===

  // Método para propagar el token a otros providers
  void propagarToken(Map<String, dynamic> providers) {
    if (_token == null) {
      print('⚠️ No hay token para propagar');
      return;
    }

    providers.forEach((key, provider) {
      if (provider is TokenReceiver) {
        provider.setToken(_token!);
        print('✅ Token propagado a: $key');
      }
    });
  }

  // Método para verificar si el token es válido
  Future<bool> verificarTokenValido() async {
    if (_token == null) {
      print('❌ No hay token para verificar');
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      final valido = response.statusCode == 200;
      print('🔐 Token válido: $valido');
      return valido;
    } catch (e) {
      print('❌ Error al verificar token: $e');
      return false;
    }
  }

  // Método para obtener información del token
  Map<String, dynamic>? getTokenInfo() {
    if (_token == null) return null;

    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded);

      print('🔍 Información del token:');
      print('   - Sub: ${payloadMap['sub']}');
      print('   - Tipo: ${payloadMap['tipo']}');
      print(
          '   - Exp: ${DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000)}');

      return payloadMap;
    } catch (e) {
      print('❌ Error al decodificar token: $e');
      return null;
    }
  }
}

// Interface para providers que pueden recibir tokens
abstract class TokenReceiver {
  void setToken(String token);
}
