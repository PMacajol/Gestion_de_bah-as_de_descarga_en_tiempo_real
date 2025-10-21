// mantenimiento_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MantenimientoProvider with ChangeNotifier {
  final List<dynamic> _mantenimientos = [];
  String? _token;
  final String _baseUrl = 'http://localhost:8000/api';

  List<dynamic> get mantenimientos => _mantenimientos;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // 🆕 Obtener todos los mantenimientos del sistema
  Future<List<dynamic>> obtenerTodosLosMantenimientos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Error al cargar mantenimientos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear mantenimiento
  Future<void> crearMantenimiento(
    String bahiaId,
    String tipo, // 'preventivo' o 'correctivo'
    String descripcion,
    DateTime fechaInicio,
    DateTime fechaFinProgramada, {
    String? tecnicoResponsable,
    double? costo,
    String? observaciones,
  }) async {
    try {
      // Formatear fechas sin zona horaria
      final inicioSinTz = DateTime(
        fechaInicio.year,
        fechaInicio.month,
        fechaInicio.day,
        fechaInicio.hour,
        fechaInicio.minute,
      );

      final finSinTz = DateTime(
        fechaFinProgramada.year,
        fechaFinProgramada.month,
        fechaFinProgramada.day,
        fechaFinProgramada.hour,
        fechaFinProgramada.minute,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/mantenimientos/'),
        headers: _headers(),
        body: json.encode({
          'bahia_id': bahiaId,
          'tipo_mantenimiento': tipo,
          'descripcion': descripcion,
          'fecha_inicio': inicioSinTz.toIso8601String().split('.').first,
          'fecha_fin_programada': finSinTz.toIso8601String().split('.').first,
          'tecnico_responsable': tecnicoResponsable,
          'costo': costo,
          'observaciones': observaciones,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Mantenimiento creado exitosamente');
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear mantenimiento');
      }
    } catch (e) {
      print('❌ Error en crearMantenimiento: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 🆕 Iniciar mantenimiento (cambiar de 'programado' a 'en_progreso')
  Future<void> iniciarMantenimiento(String bahiaId) async {
    try {
      // Buscar mantenimientos de la bahía
      final mantenimientos = await obtenerMantenimientosBahia(bahiaId);

      // Buscar mantenimiento programado
      final mantenimientoProgramado = mantenimientos.firstWhere(
        (m) => m['estado'] == 'programado',
        orElse: () =>
            throw Exception('No hay mantenimiento programado para iniciar'),
      );

      final mantenimientoId = mantenimientoProgramado['id'];

      // Iniciar el mantenimiento
      final response = await http.put(
        Uri.parse('$_baseUrl/mantenimientos/$mantenimientoId/iniciar'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Mantenimiento iniciado');
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['detail'] ?? 'Error al iniciar mantenimiento');
      }
    } catch (e) {
      print('❌ Error en iniciarMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // 🆕 Completar mantenimiento con observaciones
  Future<void> completarMantenimiento(String bahiaId,
      {String? observaciones}) async {
    try {
      // Obtener mantenimientos de la bahía
      final mantenimientos = await obtenerMantenimientosBahia(bahiaId);

      // Buscar mantenimiento activo (programado o en_progreso)
      final mantenimientoActivo = mantenimientos.firstWhere(
        (m) => m['estado'] == 'programado' || m['estado'] == 'en_progreso',
        orElse: () =>
            throw Exception('No hay mantenimiento activo para completar'),
      );

      final mantenimientoId = mantenimientoActivo['id'];
      final estadoActual = mantenimientoActivo['estado'];

      // Si está programado, primero iniciarlo
      if (estadoActual == 'programado') {
        final iniciarResponse = await http.put(
          Uri.parse('$_baseUrl/mantenimientos/$mantenimientoId/iniciar'),
          headers: _headers(),
        );

        if (iniciarResponse.statusCode != 200) {
          final errorData = json.decode(iniciarResponse.body);
          throw Exception(
              errorData['detail'] ?? 'Error al iniciar mantenimiento');
        }
        print('✅ Mantenimiento iniciado automáticamente');
      }

      // Completar el mantenimiento
      final url = observaciones != null && observaciones.isNotEmpty
          ? '$_baseUrl/mantenimientos/$mantenimientoId/completar?observaciones=${Uri.encodeComponent(observaciones)}'
          : '$_baseUrl/mantenimientos/$mantenimientoId/completar';

      final completarResponse = await http.put(
        Uri.parse(url),
        headers: _headers(),
      );

      if (completarResponse.statusCode == 200) {
        print('✅ Mantenimiento completado');
        notifyListeners();
      } else {
        final errorData = json.decode(completarResponse.body);
        throw Exception(
            errorData['detail'] ?? 'Error al completar mantenimiento');
      }
    } catch (e) {
      print('❌ Error en completarMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // 🆕 Cancelar mantenimiento
  Future<void> cancelarMantenimiento(String bahiaId, String motivo) async {
    try {
      // Obtener mantenimientos de la bahía
      final mantenimientos = await obtenerMantenimientosBahia(bahiaId);

      // Buscar mantenimiento activo (programado o en_progreso)
      final mantenimientoActivo = mantenimientos.firstWhere(
        (m) => m['estado'] == 'programado' || m['estado'] == 'en_progreso',
        orElse: () =>
            throw Exception('No hay mantenimiento activo para cancelar'),
      );

      final mantenimientoId = mantenimientoActivo['id'];

      // Cancelar el mantenimiento
      final response = await http.put(
        Uri.parse(
            '$_baseUrl/mantenimientos/$mantenimientoId/cancelar?motivo=${Uri.encodeComponent(motivo)}'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Mantenimiento cancelado');
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['detail'] ?? 'Error al cancelar mantenimiento');
      }
    } catch (e) {
      print('❌ Error en cancelarMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // Obtener mantenimientos de una bahía específica
  Future<List<dynamic>> obtenerMantenimientosBahia(String bahiaId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/bahia/$bahiaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al cargar mantenimientos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un mantenimiento específico por ID
  Future<Map<String, dynamic>> obtenerMantenimiento(
      String mantenimientoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/$mantenimientoId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al obtener mantenimiento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar mantenimiento
  Future<void> actualizarMantenimiento(
    String mantenimientoId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/mantenimientos/$mantenimientoId'),
        headers: _headers(),
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        print('✅ Mantenimiento actualizado');
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['detail'] ?? 'Error al actualizar mantenimiento');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas de mantenimientos
  Future<Map<String, dynamic>> obtenerEstadisticasMantenimientos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      String url = '$_baseUrl/mantenimientos/estadisticas';

      if (fechaInicio != null && fechaFin != null) {
        url += '?fecha_inicio=${fechaInicio.toIso8601String().split('T')[0]}'
            '&fecha_fin=${fechaFin.toIso8601String().split('T')[0]}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Limpiar lista local
  void limpiarMantenimientos() {
    _mantenimientos.clear();
    notifyListeners();
  }
}
