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
  final String _baseUrl =
      'https://bahiarealtime-czbxgfg4c4g3f0e6.canadacentral-01.azurewebsites.net/api';

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

  Future<void> iniciarUsoDesdeBahiaReservada(String bahiaId) async {
    try {
      print('🔄 Iniciando uso de bahía reservada...');

      final response = await http.put(
        Uri.parse('$_baseUrl/bahias/$bahiaId/iniciar-uso'),
        headers: _headers(),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Bahía puesta en uso correctamente');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al iniciar uso');
      }
    } catch (e) {
      print('❌ Error en iniciarUsoDesdeBahiaReservada: $e');
      rethrow;
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
  // AGREGAR/REEMPLAZAR ESTOS MÉTODOS EN BahiaProvider
// Sin necesidad de modificar el backend

  Future<void> ponerEnUsoMejorado(
      String bahiaId, String placa, String conductor, String mercancia) async {
    try {
      print('🔄 Poniendo bahía en uso (sin cambios en backend)...');

      // Crear reserva que comience AHORA (no en el futuro)
      final ahora = DateTime.now();
      final fin = ahora.add(Duration(hours: 2));

      // Sin zona horaria
      final inicioSinTz = DateTime(ahora.year, ahora.month, ahora.day,
          ahora.hour, ahora.minute, ahora.second);
      final finSinTz = DateTime(
          fin.year, fin.month, fin.day, fin.hour, fin.minute, fin.second);

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

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Reserva creada que comienza ahora');

        // Esperar 2 segundos para que el backend procese
        await Future.delayed(Duration(seconds: 2));

        // Recargar bahías para obtener el nuevo estado
        await cargarBahias();

        print('✅ Bahía puesta en uso correctamente');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al poner en uso');
      }
    } catch (e) {
      print('❌ Error en ponerEnUsoMejorado: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> debugBahia(String bahiaId) async {
    try {
      print('🔍 DEBUG: Información de bahía $bahiaId');

      final info = <String, dynamic>{
        'bahia_id': bahiaId,
        'reservas': [],
        'mantenimientos': [],
      };

      // Buscar reservas
      try {
        final reservasResponse = await http.get(
          Uri.parse('$_baseUrl/reservas/?bahia_id=$bahiaId'),
          headers: _headers(),
        );

        if (reservasResponse.statusCode == 200) {
          final List<dynamic> reservas = json.decode(reservasResponse.body);
          info['reservas'] = reservas;
          print('📋 Reservas encontradas: ${reservas.length}');
          for (var r in reservas) {
            print(
                '   - ${r['id']}: ${r['estado']} (${r['fecha_hora_inicio']} - ${r['fecha_hora_fin']})');
          }
        }
      } catch (e) {
        print('⚠️ Error al buscar reservas: $e');
      }

      // Buscar mantenimientos
      try {
        final mantResponse = await http.get(
          Uri.parse('$_baseUrl/mantenimientos/?bahia_id=$bahiaId'),
          headers: _headers(),
        );

        if (mantResponse.statusCode == 200) {
          final List<dynamic> mantenimientos = json.decode(mantResponse.body);
          info['mantenimientos'] = mantenimientos;
          print('🔧 Mantenimientos encontrados: ${mantenimientos.length}');
          for (var m in mantenimientos) {
            print(
                '   - ${m['id']}: ${m['estado']} (${m['tipo_mantenimiento']})');
          }
        }
      } catch (e) {
        print('⚠️ Error al buscar mantenimientos: $e');
      }

      return info;
    } catch (e) {
      print('❌ Error en debugBahia: $e');
      return {};
    }
  }

  Future<void> liberarBahiaMejorado(String bahiaId) async {
    try {
      print('🔄 Liberando bahía mejorado...');

      // Primero hacer debug para ver qué hay
      await debugBahia(bahiaId);

      // Buscar TODAS las reservas de esta bahía
      final response = await http.get(
        Uri.parse('$_baseUrl/reservas/?bahia_id=$bahiaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservas = json.decode(response.body);

        print('📋 Total reservas encontradas: ${reservas.length}');

        if (reservas.isEmpty) {
          print('⚠️ No hay reservas para esta bahía');
          throw Exception('No se encontraron reservas para completar');
        }

        // Ordenar por fecha de creación (más reciente primero)
        reservas.sort((a, b) {
          final fechaA = DateTime.parse(a['fecha_creacion']);
          final fechaB = DateTime.parse(b['fecha_creacion']);
          return fechaB.compareTo(fechaA);
        });

        // Intentar completar cada reserva que no esté completada o cancelada
        bool algunaCompletada = false;

        for (var reserva in reservas) {
          final estado = reserva['estado'].toString().toLowerCase();
          final reservaId = reserva['id'];

          print('🔍 Revisando reserva $reservaId: $estado');

          if (estado != 'completada' && estado != 'cancelada') {
            print('🔄 Intentando completar reserva $reservaId...');

            try {
              final completarResponse = await http.put(
                Uri.parse('$_baseUrl/reservas/$reservaId/completar'),
                headers: _headers(),
              );

              print('📥 Completar response: ${completarResponse.statusCode}');
              print('📥 Body: ${completarResponse.body}');

              if (completarResponse.statusCode == 200) {
                print('✅ Reserva $reservaId completada correctamente');
                algunaCompletada = true;
                break; // Solo necesitamos completar una
              } else {
                print(
                    '⚠️ No se pudo completar $reservaId: ${completarResponse.body}');
              }
            } catch (e) {
              print('⚠️ Error al completar reserva $reservaId: $e');
            }
          }
        }

        if (!algunaCompletada) {
          print('⚠️ No se pudo completar ninguna reserva');
          throw Exception('No se pudo completar ninguna reserva');
        }
      } else {
        print('❌ Error al buscar reservas: ${response.statusCode}');
        throw Exception('Error al buscar reservas');
      }

      // Esperar un momento y recargar
      print('⏳ Esperando actualización...');
      await Future.delayed(Duration(seconds: 2));
      await cargarBahias();

      print('✅ Proceso de liberación completado');
    } catch (e) {
      print('❌ Error en liberarBahiaMejorado: $e');
      rethrow;
    }
  }

  Future<void> forzarLiberacionCompleta(String bahiaId) async {
    try {
      print('🔄 Forzando liberación completa...');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      bool algunaAccionRealizada = false;

      // Debug inicial
      print('🔍 Estado inicial:');
      await debugBahia(bahiaId);

      // PASO 1: Completar todas las reservas
      try {
        print('\n📋 PASO 1: Procesando reservas...');
        final response = await http.get(
          Uri.parse('$_baseUrl/reservas/?bahia_id=$bahiaId'),
          headers: _headers(),
        );

        if (response.statusCode == 200) {
          final List<dynamic> reservas = json.decode(response.body);
          print('   Reservas encontradas: ${reservas.length}');

          for (var reserva in reservas) {
            final estado = reserva['estado'];
            final reservaId = reserva['id'];

            print('   → Reserva $reservaId: $estado');

            if (estado == 'activa') {
              // Intentar completar
              try {
                print('   🔄 Completando...');
                final completarResponse = await http.put(
                  Uri.parse('$_baseUrl/reservas/$reservaId/completar'),
                  headers: _headers(),
                );

                if (completarResponse.statusCode == 200) {
                  print('   ✅ COMPLETADA');
                  algunaAccionRealizada = true;
                } else {
                  print('   ⚠️ No completada: ${completarResponse.statusCode}');
                  print('      ${completarResponse.body}');
                }
              } catch (e) {
                print('   ⚠️ Error al completar: $e');

                // Intentar cancelar como alternativa
                try {
                  print('   🔄 Intentando cancelar...');
                  final cancelarResponse = await http.put(
                    Uri.parse(
                        '$_baseUrl/reservas/$reservaId/cancelar?motivo=Liberación forzada'),
                    headers: _headers(),
                  );

                  if (cancelarResponse.statusCode == 200) {
                    print('   ✅ CANCELADA');
                    algunaAccionRealizada = true;
                  }
                } catch (e2) {
                  print('   ❌ Tampoco se pudo cancelar: $e2');
                }
              }
            }
          }
        }
      } catch (e) {
        print('   ❌ Error en paso de reservas: $e');
      }

      // PASO 2: Completar todos los mantenimientos
      try {
        print('\n🔧 PASO 2: Procesando mantenimientos...');
        final response = await http.get(
          Uri.parse('$_baseUrl/mantenimientos/?bahia_id=$bahiaId'),
          headers: _headers(),
        );

        if (response.statusCode == 200) {
          final List<dynamic> mantenimientos = json.decode(response.body);
          print('   Mantenimientos encontrados: ${mantenimientos.length}');

          for (var mant in mantenimientos) {
            final estado = mant['estado'];
            final mantId = mant['id'];

            print('   → Mantenimiento $mantId: $estado');

            if (estado == 'programado' || estado == 'en_progreso') {
              try {
                // Si está programado, iniciarlo primero
                if (estado == 'programado') {
                  print('   🔄 Iniciando...');
                  await http.put(
                    Uri.parse('$_baseUrl/mantenimientos/$mantId/iniciar'),
                    headers: _headers(),
                  );
                  print('   ✅ Iniciado');
                  await Future.delayed(Duration(milliseconds: 500));
                }

                // Completar
                print('   🔄 Completando...');
                final completarResponse = await http.put(
                  Uri.parse(
                      '$_baseUrl/mantenimientos/$mantId/completar?observaciones=Completado por liberación forzada'),
                  headers: _headers(),
                );

                if (completarResponse.statusCode == 200) {
                  print('   ✅ COMPLETADO');
                  algunaAccionRealizada = true;
                } else {
                  print('   ⚠️ No completado: ${completarResponse.statusCode}');
                }
              } catch (e) {
                print('   ⚠️ Error al completar: $e');

                // Intentar cancelar
                try {
                  print('   🔄 Intentando cancelar...');
                  await http.put(
                    Uri.parse(
                        '$_baseUrl/mantenimientos/$mantId/cancelar?motivo=Liberación forzada'),
                    headers: _headers(),
                  );
                  print('   ✅ CANCELADO');
                  algunaAccionRealizada = true;
                } catch (e2) {
                  print('   ❌ Tampoco se pudo cancelar: $e2');
                }
              }
            }
          }
        }
      } catch (e) {
        print('   ❌ Error en paso de mantenimientos: $e');
      }

      // PASO 3: Recargar
      print('\n⏳ PASO 3: Recargando datos...');
      await Future.delayed(Duration(seconds: 2));
      await cargarBahias();

      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (algunaAccionRealizada) {
        print('✅ Liberación forzada completada con éxito');
      } else {
        print(
            '⚠️ No se realizaron acciones (no había reservas/mantenimientos activos)');
      }
    } catch (e) {
      print('❌ Error en forzarLiberacionCompleta: $e');
      rethrow;
    }
  }

  Future<void> iniciarUsoDesdeReserva(String bahiaId) async {
    try {
      print('🔄 Iniciando uso desde reserva...');

      // Buscar la reserva activa
      final response = await http.get(
        Uri.parse('$_baseUrl/reservas/?bahia_id=$bahiaId&estado=activa'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reservas = json.decode(response.body);

        if (reservas.isEmpty) {
          throw Exception('No se encontró reserva activa para esta bahía');
        }

        final reserva = reservas.first;
        final reservaId = reserva['id'];

        print('📋 Reserva encontrada: $reservaId');

        // La reserva ya existe, solo necesitamos esperar a que el sistema
        // la reconozca como "en uso" cuando llegue su hora de inicio
        // O podríamos actualizarla para que inicie ahora

        // Por ahora, simplemente recargamos
        await Future.delayed(Duration(seconds: 1));
        await cargarBahias();

        print('✅ Reserva lista para uso');
      } else {
        throw Exception('Error al buscar reserva');
      }
    } catch (e) {
      print('❌ Error en iniciarUsoDesdeReserva: $e');
      throw Exception('Error: $e');
    }
  }

// === CREAR BAHÍA ===
  Future<void> crearBahia({
    required int numero,
    required TipoBahia tipo,
    required EstadoBahia estado,
    required double capacidadMaxima,
    required String ubicacion,
    String? observaciones,
  }) async {
    try {
      print('🔄 Creando bahía...');

      final body = {
        "numero": numero,
        "tipo_bahia_id": _getTipoBahiaIdFromEnum(tipo),
        "estado_bahia_id": _getEstadoBahiaIdFromEnum(estado),
        "capacidad_maxima": capacidadMaxima,
        "ubicacion": ubicacion,
        "observaciones": observaciones ?? "",
        // No enviar 'activo', el backend lo establece automáticamente
      };

      print('📤 Datos a enviar: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/bahias/'),
        headers: _headers(),
        body: json.encode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Bahía creada correctamente');
        await cargarBahias(); // Recargar la lista
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error del servidor: $errorData');
        throw Exception(errorData['detail'] ?? 'Error al crear bahía');
      }
    } catch (e) {
      print('❌ Error en crearBahia: $e');
      rethrow; // Re-lanzar el error para que el dashboard lo capture
    }
  }

// === ELIMINAR BAHÍA ===
  Future<void> eliminarBahia(String id) async {
    try {
      print('🔄 Eliminando bahía $id...');

      final response = await http.delete(
        Uri.parse('$_baseUrl/bahias/$id'),
        headers: _headers(),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Bahía eliminada correctamente');
        await cargarBahias();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar bahía');
      }
    } catch (e) {
      print('❌ Error en eliminarBahia: $e');
      rethrow;
    }
  }

// Métodos auxiliares para convertir enums a IDs
  int _getTipoBahiaIdFromEnum(TipoBahia tipo) {
    switch (tipo) {
      case TipoBahia.estandar:
        return 1;
      case TipoBahia.refrigerada:
        return 2;
      case TipoBahia.peligrosos:
        return 3;
      case TipoBahia.sobremodida:
        return 4;
    }
  }

  int _getEstadoBahiaIdFromEnum(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return 1;
      case EstadoBahia.reservada:
        return 2;
      case EstadoBahia.enUso:
        return 3;
      case EstadoBahia.mantenimiento:
        return 4;
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
