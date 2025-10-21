import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bahias_descarga_system/models/bahia_model.dart';

abstract class TokenReceiver {
  void setToken(String token);
}

class BahiaProvider with ChangeNotifier implements TokenReceiver {
  List<Bahia> _bahias = [];
  List<Bahia> _bahiasFiltradas = [];
  String _terminoBusqueda = '';
  String? _token;
  final String _baseUrl = 'http://localhost:8000/api';

  List<Bahia> get bahias =>
      _terminoBusqueda.isEmpty ? _bahias : _bahiasFiltradas;

  @override
  void setToken(String token) {
    _token = token;
    print(
        '🔑 Token establecido en BahiaProvider: ${token.substring(0, 20)}...');
  }

  // === CARGAR BAHÍAS ===
  Future<void> cargarBahias() async {
    try {
      print('🔄 Cargando bahías...');
      final headers = {'Content-Type': 'application/json'};
      if (_token != null) headers['Authorization'] = 'Bearer $_token';

      final response = await http.get(
        Uri.parse('$_baseUrl/bahias/'),
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bahias = data.map((json) => Bahia.fromJson(json)).toList();
        _bahiasFiltradas = _bahias;
        notifyListeners();
      } else {
        throw Exception('Error al cargar las bahías: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en cargarBahias: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // === OBTENER BAHÍA ESPECÍFICA ===
  Future<Bahia> obtenerBahia(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bahias/$id'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return Bahia.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener bahía: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // === ESTADOS Y TIPOS ===
  Future<List<dynamic>> cargarEstadosBahia() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bahias/estados/'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> cargarTiposBahia() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bahias/tipos/'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar tipos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ MÉTODO AUXILIAR: Obtener reserva activa de una bahía
  Future<String?> _obtenerReservaActiva(String bahiaId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reservas/?bahia_id=$bahiaId&estado=activa'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservas = json.decode(response.body);
        if (reservas.isNotEmpty) {
          return reservas[0]['id'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error al buscar reserva activa: $e');
      return null;
    }
  }

  // ✅ CORREGIDO: Poner en uso (crear reserva inmediata)
  Future<void> ponerEnUso(
      String bahiaId, String placa, String conductor, String mercancia) async {
    try {
      // Crear una reserva que inicie 1 minuto en el futuro (para evitar error de "pasado")
      final ahora = DateTime.now().add(Duration(minutes: 1));
      final fin =
          ahora.add(Duration(hours: 2)); // Reserva de 2 horas por defecto

      // Formatear fechas sin zona horaria (formato que espera el backend)
      final inicioSinTz = DateTime(
          ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute);
      final finSinTz =
          DateTime(fin.year, fin.month, fin.day, fin.hour, fin.minute);

      final response = await http.post(
        Uri.parse('$_baseUrl/reservas/'),
        headers: _headers(),
        body: json.encode({
          'bahia_id': bahiaId,
          'fecha_hora_inicio': inicioSinTz.toIso8601String(),
          'fecha_hora_fin': finSinTz.toIso8601String(),
          'vehiculo_placa': placa,
          'conductor_nombre': conductor,
          'mercancia_descripcion': mercancia,
          'observaciones': 'Puesto en uso desde administración',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Bahía puesta en uso');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al poner en uso');
      }
    } catch (e) {
      print('❌ Error en ponerEnUso: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ CORREGIDO: Poner en mantenimiento
  Future<void> ponerEnMantenimiento(
      String bahiaId, String observaciones) async {
    try {
      final ahora =
          DateTime.now().add(Duration(minutes: 1)); // 1 minuto en el futuro
      final finProgramado =
          ahora.add(Duration(hours: 4)); // 4 horas por defecto

      // Formatear sin zona horaria
      final inicioSinTz = DateTime(
          ahora.year, ahora.month, ahora.day, ahora.hour, ahora.minute);
      final finSinTz = DateTime(finProgramado.year, finProgramado.month,
          finProgramado.day, finProgramado.hour, finProgramado.minute);

      final response = await http.post(
        Uri.parse('$_baseUrl/mantenimientos/'),
        headers: _headers(),
        body: json.encode({
          'bahia_id': bahiaId,
          'tipo_mantenimiento': 'correctivo',
          'descripcion': observaciones,
          'fecha_inicio': inicioSinTz.toIso8601String(),
          'fecha_fin_programada': finSinTz.toIso8601String(),
          'observaciones': observaciones,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Bahía en mantenimiento');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['detail'] ?? 'Error al poner en mantenimiento');
      }
    } catch (e) {
      print('❌ Error en ponerEnMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ CORREGIDO: Reservar bahía
  Future<void> reservarBahia({
    required String bahiaId,
    required DateTime inicio,
    required DateTime fin,
    required String placa,
    required String conductor,
    required String telefono,
    required String mercancia,
    required String tipo,
    required double peso,
  }) async {
    try {
      final body = {
        "bahia_id": bahiaId,
        "fecha_hora_inicio": inicio.toIso8601String(),
        "fecha_hora_fin": fin.toIso8601String(),
        "vehiculo_placa": placa,
        "conductor_nombre": conductor,
        "conductor_telefono": telefono,
        "mercancia_tipo": tipo,
        "mercancia_peso": peso,
        "mercancia_descripcion": mercancia,
        "observaciones": "Reserva generada desde app Flutter"
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/reservas/'),
        headers: _headers(),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Reserva creada correctamente');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear reserva');
      }
    } catch (e) {
      print('❌ Error en reservarBahia: $e');
      throw Exception('Error: $e');
    }
  }

  // Verificar disponibilidad
  Future<Map<String, dynamic>> verificarDisponibilidad(String bahiaId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/reservas/disponibilidad/verificar?bahia_id=$bahiaId'),
        headers: _headers(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al verificar disponibilidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ CORREGIDO: Liberar bahía (completar reserva activa)
  Future<void> liberarBahia(String bahiaId) async {
    try {
      // Buscar reserva activa
      final reservaId = await _obtenerReservaActiva(bahiaId);

      if (reservaId == null) {
        throw Exception('No hay una reserva activa para liberar');
      }

      // Completar la reserva
      final response = await http.put(
        Uri.parse('$_baseUrl/reservas/$reservaId/completar'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Bahía liberada');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al liberar bahía');
      }
    } catch (e) {
      print('❌ Error en liberarBahia: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ NUEVO: Iniciar mantenimiento (cambiar de programado a en_progreso)
  Future<void> iniciarMantenimiento(String bahiaId) async {
    try {
      // Obtener mantenimientos programados de la bahía
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/?bahia_id=$bahiaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> mantenimientos = json.decode(response.body);

        // Buscar mantenimiento programado
        final mantenimientoProgramado = mantenimientos.firstWhere(
          (m) => m['estado'] == 'programado',
          orElse: () => null,
        );

        if (mantenimientoProgramado == null) {
          throw Exception('No hay mantenimiento programado para iniciar');
        }

        final mantenimientoId = mantenimientoProgramado['id'];

        // Iniciar el mantenimiento usando el endpoint correcto
        final iniciarResponse = await http.put(
          Uri.parse('$_baseUrl/mantenimientos/$mantenimientoId/iniciar'),
          headers: _headers(),
        );

        if (iniciarResponse.statusCode == 200) {
          print('✅ Mantenimiento iniciado');
          await cargarBahias();
        } else {
          final errorData = json.decode(iniciarResponse.body);
          throw Exception(
              errorData['detail'] ?? 'Error al iniciar mantenimiento');
        }
      } else {
        throw Exception('Error al buscar mantenimientos');
      }
    } catch (e) {
      print('❌ Error en iniciarMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ CORREGIDO: Liberar de mantenimiento (completar con observaciones opcionales)
  Future<void> liberarDeMantenimiento(String bahiaId,
      {String? observaciones}) async {
    try {
      // Obtener mantenimientos activos de la bahía
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/?bahia_id=$bahiaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> mantenimientos = json.decode(response.body);

        // Buscar mantenimiento activo (programado o en_progreso)
        final mantenimientoActivo = mantenimientos.firstWhere(
          (m) => m['estado'] == 'programado' || m['estado'] == 'en_progreso',
          orElse: () => null,
        );

        if (mantenimientoActivo == null) {
          throw Exception('No hay mantenimiento activo para completar');
        }

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

        // Ahora completar el mantenimiento
        final url = observaciones != null && observaciones.isNotEmpty
            ? '$_baseUrl/mantenimientos/$mantenimientoId/completar?observaciones=${Uri.encodeComponent(observaciones)}'
            : '$_baseUrl/mantenimientos/$mantenimientoId/completar';

        final completarResponse = await http.put(
          Uri.parse(url),
          headers: _headers(),
        );

        if (completarResponse.statusCode == 200) {
          print('✅ Mantenimiento completado');
          await cargarBahias();
        } else {
          final errorData = json.decode(completarResponse.body);
          throw Exception(
              errorData['detail'] ?? 'Error al completar mantenimiento');
        }
      } else {
        throw Exception('Error al buscar mantenimientos');
      }
    } catch (e) {
      print('❌ Error en liberarDeMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ CORREGIDO: Cancelar mantenimiento
  Future<void> cancelarMantenimiento(String bahiaId, String motivo) async {
    try {
      // Obtener mantenimientos activos de la bahía
      final response = await http.get(
        Uri.parse('$_baseUrl/mantenimientos/?bahia_id=$bahiaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> mantenimientos = json.decode(response.body);

        // Buscar mantenimiento activo (programado o en_progreso)
        final mantenimientoActivo = mantenimientos.firstWhere(
          (m) => m['estado'] == 'programado' || m['estado'] == 'en_progreso',
          orElse: () => null,
        );

        if (mantenimientoActivo == null) {
          throw Exception('No hay mantenimiento activo para cancelar');
        }

        final mantenimientoId = mantenimientoActivo['id'];

        // Cancelar el mantenimiento usando el endpoint correcto
        final cancelarResponse = await http.put(
          Uri.parse(
              '$_baseUrl/mantenimientos/$mantenimientoId/cancelar?motivo=${Uri.encodeComponent(motivo)}'),
          headers: _headers(),
        );

        if (cancelarResponse.statusCode == 200) {
          print('✅ Mantenimiento cancelado');
          await cargarBahias();
        } else {
          final errorData = json.decode(cancelarResponse.body);
          throw Exception(
              errorData['detail'] ?? 'Error al cancelar mantenimiento');
        }
      } else {
        throw Exception('Error al buscar mantenimientos');
      }
    } catch (e) {
      print('❌ Error en cancelarMantenimiento: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ CORREGIDO: Cancelar reserva
  Future<void> cancelarReservaBahia(String bahiaId) async {
    try {
      // Buscar reserva activa
      final reservaId = await _obtenerReservaActiva(bahiaId);

      if (reservaId == null) {
        throw Exception('No hay una reserva activa para cancelar');
      }

      // Cancelar la reserva
      final response = await http.put(
        Uri.parse(
            '$_baseUrl/reservas/$reservaId/cancelar?motivo=Cancelada desde administración'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        print('✅ Reserva cancelada');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al cancelar reserva');
      }
    } catch (e) {
      print('❌ Error en cancelarReservaBahia: $e');
      throw Exception('Error: $e');
    }
  }

  // === BÚSQUEDA LOCAL ===
  void buscarBahias(String termino) {
    _terminoBusqueda = termino.toLowerCase();
    _bahiasFiltradas = _bahias.where((b) {
      return b.numero.toString().contains(_terminoBusqueda) ||
          b.nombreTipo.toLowerCase().contains(_terminoBusqueda) ||
          b.nombreEstado.toLowerCase().contains(_terminoBusqueda);
    }).toList();
    notifyListeners();
  }

  void limpiarBusqueda() {
    _terminoBusqueda = '';
    _bahiasFiltradas = _bahias;
    notifyListeners();
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
