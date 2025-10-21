import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bahias_descarga_system/models/reserva_model.dart';

class ReservaProvider with ChangeNotifier {
  List<Reserva> _reservas = [];
  String? _token;
  final String _baseUrl = 'http://localhost:8000/api';

  List<Reserva> get reservas => _reservas;

  void setToken(String token) {
    _token = token;
  }

  Future<void> cargarReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reservas/'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _reservas = data.map((json) => Reserva.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Error al cargar las reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ CORREGIDO: Crear nueva reserva con formato de fecha correcto
  // ✅ Crear nueva reserva correctamente alineada con la API /api/reservas/
  Future<void> crearReserva(
    String bahiaId,
    int numeroBahia,
    String usuarioId,
    String usuarioNombre,
    DateTime inicio,
    DateTime fin, {
    String? vehiculoPlaca,
    String? conductorNombre,
    String? conductorTelefono,
    String? conductorDocumento,
    String? mercanciaTipo,
    double? mercanciaPeso,
    String? mercanciaDescripcion,
    String? observaciones,
  }) async {
    try {
      // Validaciones básicas
      if (inicio.isAfter(fin)) {
        throw Exception(
            'La fecha de inicio no puede ser posterior a la de fin.');
      }

      // Convertir fechas al formato ISO local sin "Z" (sin zona horaria)
      final formatoLocal = DateTime(
          inicio.year, inicio.month, inicio.day, inicio.hour, inicio.minute);
      final formatoFin =
          DateTime(fin.year, fin.month, fin.day, fin.hour, fin.minute);

      // 🔹 Estructura del body según tu API
      final Map<String, dynamic> body = {
        "bahia_id": bahiaId,
        "fecha_hora_inicio": formatoLocal.toIso8601String().split('.').first,
        "fecha_hora_fin": formatoFin.toIso8601String().split('.').first,
        "vehiculo_placa": vehiculoPlaca ?? "",
        "conductor_nombre": conductorNombre ?? "",
        "conductor_telefono": conductorTelefono ?? "",
        "conductor_documento": conductorDocumento ?? "",
        "mercancia_tipo": mercanciaTipo ?? "",
        "mercancia_peso": mercanciaPeso ?? 0,
        "mercancia_descripcion": mercanciaDescripcion ?? "",
        "observaciones": observaciones ?? "",
        // 🔸 Si tu backend requiere usuario, agrégalo:
        "usuario_id": usuarioId,
        "creado_por": usuarioNombre,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/reservas/'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await cargarReservas();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ??
            'Error al crear la reserva (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error al crear la reserva: $e');
    }
  }

  Future<Reserva> obtenerReserva(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reservas/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Reserva.fromJson(data);
      } else {
        throw Exception('Error al obtener reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cancelarReserva(String reservaId) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$_baseUrl/reservas/$reservaId/cancelar?motivo=Cancelado por el usuario'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await cargarReservas();
      } else {
        throw Exception('Error al cancelar reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> completarReserva(String reservaId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/reservas/$reservaId/completar'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await cargarReservas();
      } else {
        throw Exception('Error al completar reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerEstadisticasUso(
      DateTime inicio, DateTime fin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reportes/uso/rango'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'fecha_inicio': inicio.toIso8601String().split('T')[0],
          'fecha_fin': fin.toIso8601String().split('T')[0],
        }),
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

  Future<Map<String, dynamic>> obtenerReporteDiario(DateTime fecha) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/reportes/uso/diario?fecha=${fecha.toIso8601String().split('T')[0]}'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Error al obtener reporte diario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Reserva>> obtenerReservasActivasBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reportes/reservas/activas'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reservasData = data['reservas'] ?? [];
        return reservasData.map((json) => Reserva.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener reservas activas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerIndicadoresDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reportes/dashboard/indicadores'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener indicadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // MÉTODOS DE FILTRADO LOCAL
  List<Reserva> obtenerReservasPorUsuario(String usuarioId) {
    return _reservas
        .where((reserva) => reserva.usuarioId == usuarioId)
        .toList();
  }

  List<Reserva> obtenerReservasPorBahia(String bahiaId) {
    return _reservas.where((reserva) => reserva.bahiaId == bahiaId).toList();
  }

  List<Reserva> obtenerReservasActivas() {
    return _reservas.where((reserva) => reserva.estaActiva).toList();
  }

  List<Reserva> obtenerReservasCompletadas() {
    return _reservas.where((reserva) => reserva.estaCompletada).toList();
  }

  List<Reserva> obtenerReservasCanceladas() {
    return _reservas.where((reserva) => reserva.estaCancelada).toList();
  }

  List<Reserva> obtenerReservasPorFecha(DateTime fecha) {
    return _reservas.where((reserva) {
      return reserva.fechaHoraInicio.year == fecha.year &&
          reserva.fechaHoraInicio.month == fecha.month &&
          reserva.fechaHoraInicio.day == fecha.day;
    }).toList();
  }

  Reserva? obtenerReservaPorId(String reservaId) {
    try {
      return _reservas.firstWhere((reserva) => reserva.id == reservaId);
    } catch (e) {
      return null;
    }
  }

  Future<void> actualizarReserva(
      String reservaId, Reserva reservaActualizada) async {
    final index = _reservas.indexWhere((reserva) => reserva.id == reservaId);
    if (index != -1) {
      _reservas[index] = reservaActualizada;
      notifyListeners();
    }
  }

  Future<void> reactivarReserva(String reservaId) async {
    final index = _reservas.indexWhere((reserva) => reserva.id == reservaId);
    if (index != -1) {
      _reservas[index] = _reservas[index].copyWith(estado: 'activa');
      notifyListeners();
    }
  }

  Future<void> eliminarReserva(String reservaId) async {
    _reservas.removeWhere((reserva) => reserva.id == reservaId);
    notifyListeners();
  }
}
